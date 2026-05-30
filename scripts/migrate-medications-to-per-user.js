#!/usr/bin/env node
/**
 * One-time migration: shared pet medications -> private per-user medications.
 *
 * Old model: pets/{petId}/medications/{medId}   (shared across the care circle)
 * New model: users/{uid}/medications/{medId}    (private per user, carries petId)
 *
 * For each pet, every medication under pets/{petId}/medications is copied into
 * the target user(s)' users/{uid}/medications collection with a `petId` field
 * added. The original doc ID is preserved. Old docs are left in place (they
 * become inaccessible once the new Firestore rules are deployed); pass
 * --delete-old to remove them after a successful copy.
 *
 * Target selection (--target):
 *   owner  (default)  copy each med to the pet's ownerId only
 *   all               copy each med to every uid in the pet's memberUids
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *     node scripts/migrate-medications-to-per-user.js [--dry-run] [--target owner|all] [--delete-old]
 *
 * Credentials: provide a service-account JSON via GOOGLE_APPLICATION_CREDENTIALS,
 * or run inside an environment with application-default credentials for the
 * pet-circle-app project. The Admin SDK bypasses security rules, so this script
 * may be run either before or after deploying the new firestore.rules.
 */

const path = require('path');

// Resolve firebase-admin from the functions workspace (already installed there).
const admin = require(path.join(__dirname, '..', 'functions', 'node_modules', 'firebase-admin'));

const PROJECT_ID = 'pet-circle-app';

function parseArgs(argv) {
  const args = { dryRun: false, target: 'owner', deleteOld: false };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--dry-run') args.dryRun = true;
    else if (a === '--delete-old') args.deleteOld = true;
    else if (a === '--target') {
      args.target = argv[++i];
    } else {
      throw new Error(`Unknown argument: ${a}`);
    }
  }
  if (args.target !== 'owner' && args.target !== 'all') {
    throw new Error(`--target must be "owner" or "all" (got "${args.target}")`);
  }
  return args;
}

function targetUidsForPet(petData, target) {
  if (target === 'all') {
    const uids = Array.isArray(petData.memberUids) ? petData.memberUids : [];
    // Always include the owner even if memberUids is incomplete.
    if (petData.ownerId && !uids.includes(petData.ownerId)) uids.push(petData.ownerId);
    return uids.filter(Boolean);
  }
  return petData.ownerId ? [petData.ownerId] : [];
}

async function main() {
  const args = parseArgs(process.argv);

  admin.initializeApp({ projectId: PROJECT_ID });
  const db = admin.firestore();

  console.log(
    `Migration starting — target=${args.target}, dryRun=${args.dryRun}, deleteOld=${args.deleteOld}`,
  );

  const petsSnap = await db.collection('pets').get();
  console.log(`Found ${petsSnap.size} pet(s).`);

  let copied = 0;
  let skippedNoTarget = 0;
  let deleted = 0;

  for (const petDoc of petsSnap.docs) {
    const petId = petDoc.id;
    const petData = petDoc.data() || {};
    const uids = targetUidsForPet(petData, args.target);

    const medsSnap = await petDoc.ref.collection('medications').get();
    if (medsSnap.empty) continue;

    if (uids.length === 0) {
      console.warn(
        `  pet ${petId}: ${medsSnap.size} med(s) but no target uid (missing ownerId/memberUids) — skipping`,
      );
      skippedNoTarget += medsSnap.size;
      continue;
    }

    console.log(
      `  pet ${petId}: ${medsSnap.size} med(s) -> ${uids.length} user(s) [${uids.join(', ')}]`,
    );

    for (const medDoc of medsSnap.docs) {
      const medData = { ...medDoc.data(), petId };
      for (const uid of uids) {
        const destRef = db
          .collection('users')
          .doc(uid)
          .collection('medications')
          .doc(medDoc.id);
        if (args.dryRun) {
          console.log(`    [dry-run] would write users/${uid}/medications/${medDoc.id}`);
        } else {
          await destRef.set(medData, { merge: false });
        }
        copied++;
      }
      if (args.deleteOld && !args.dryRun) {
        await medDoc.ref.delete();
        deleted++;
      }
    }
  }

  console.log('Migration complete.');
  console.log(`  copied: ${copied}`);
  console.log(`  skipped (no target uid): ${skippedNoTarget}`);
  if (args.deleteOld) console.log(`  old docs deleted: ${deleted}`);
  if (args.dryRun) console.log('  (dry-run: no writes were performed)');
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Migration failed:', err);
    process.exit(1);
  });
