import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import { FUNCTION_REGION } from "./config";

/**
 * Subcollections that hang off a pet document.
 *
 * Firestore does **not** cascade: deleting `pets/{petId}` leaves every one of
 * these behind. Worse, the security rules resolve access to them through the
 * parent pet document, so once that is gone the orphans are unreachable *and*
 * undeletable by any client — while still counting against storage. They have
 * to be removed with the Admin SDK, which bypasses rules.
 */
export const PET_SUBCOLLECTIONS = [
  "measurements",
  "notes",
  "medications",
  "reminders",
] as const;

/**
 * The uids that hold a reference to this pet in their `users/{uid}.petIds`.
 *
 * Read from the deleted document's own snapshot: after the delete there is no
 * other record of who was in the care circle. `memberUids` is the denormalised
 * array the pet query already uses, with the care circle as a fallback for
 * documents written before that field existed.
 *
 * Exported for unit testing — the surrounding trigger needs an emulator, this
 * does not.
 */
export function memberUidsFromPetData(
  data: FirebaseFirestore.DocumentData | undefined
): string[] {
  if (!data) return [];

  const fromArray = Array.isArray(data.memberUids) ? data.memberUids : [];
  const fromCircle = Array.isArray(data.careCircle)
    ? data.careCircle.map((m: { uid?: unknown }) => m?.uid)
    : [];

  const uids = [...fromArray, ...fromCircle].filter(
    (uid): uid is string => typeof uid === "string" && uid.length > 0
  );

  return [...new Set(uids)];
}

/**
 * Firestore trigger: cleans up everything a deleted pet leaves behind.
 *
 * Trigger path: `pets/{petId}`
 * Fires on: document delete.
 *
 * Three jobs, in order of how badly they leak:
 *  1. Recursively delete the pet's subcollections (see [PET_SUBCOLLECTIONS]).
 *  2. Drop the petId from every care-circle member's `users/{uid}.petIds`.
 *     The deleting client only ever cleans its *own* entry, so co-owners and
 *     vets are otherwise left holding a dangling reference.
 *  3. Delete invitations still pointing at the pet, which can no longer be
 *     accepted and would fail confusingly if they were.
 *
 * Every step is best-effort and independently guarded: a failure in one must
 * not strand the others, and the client has already reported success to the
 * user by the time this runs. Failures are logged loudly rather than thrown,
 * since a retry of an already-partially-applied cleanup gains nothing.
 */
export const onPetDeleted = onDocumentDeleted(
  { document: "pets/{petId}", region: FUNCTION_REGION },
  async (event) => {
    const petId = event.params.petId;
    const db = admin.firestore();

    // 1. Subcollections.
    try {
      await db.recursiveDelete(db.collection("pets").doc(petId));
    } catch (error) {
      logger.error(`Failed to recursively delete subcollections for pet ${petId}`, error);
    }

    // 2. Member back-references.
    const uids = memberUidsFromPetData(event.data?.data());
    if (uids.length > 0) {
      const batch = db.batch();
      for (const uid of uids) {
        batch.update(db.collection("users").doc(uid), {
          petIds: admin.firestore.FieldValue.arrayRemove(petId),
        });
      }
      try {
        await batch.commit();
      } catch (error) {
        logger.error(`Failed to clear petIds for pet ${petId} on ${uids.length} user(s)`, error);
      }
    }

    // 3. Dangling invitations.
    try {
      const invites = await db
        .collection("invitations")
        .where("petId", "==", petId)
        .get();
      if (!invites.empty) {
        const batch = db.batch();
        invites.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
      }
    } catch (error) {
      logger.error(`Failed to delete invitations for pet ${petId}`, error);
    }

    logger.info(`Cleaned up pet ${petId}: ${uids.length} member reference(s)`);
  }
);
