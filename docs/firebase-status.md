# Firebase Status

## Supported Now

- Firebase Auth is wired for email/password, Google, and Apple sign-in.
- Firestore is the source of truth for users, pets, measurements, notes, medications, invitations, settings, and in-app notifications.
- Invitation acceptance now requires a trusted `pendingInvites` entry on the pet document, so pet access is no longer granted by a broad self-join rule.
- Android now applies the Google Services Gradle plugin, and the repo includes a default Firebase project alias in `.firebaserc`.
- Repo-managed Firestore rules are deployed to the default Firebase project (`pet-circle-app`), and `firebase.json` now also deploys `firestore.indexes.json`.
- Cloud Functions (Node 20, TypeScript, `us-central1`) are live: `onInvitationCreated` sends invitation email via Resend, `onInvitationStatusChanged` sends the invite-accepted push plus in-app notification, and `sendOTP` / `verifyOTP` back the OTP auth flow.
- Firebase Cloud Messaging is wired end to end: device-token registration and rotation, a foreground handler, a background handler, and notification-tap routing behind a route allowlist.

## Local Setup

Generated Firebase config files remain gitignored:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

Refresh local Firebase config from the repo root with:

```bash
dart pub global activate flutterfire_cli
flutterfire configure \
  --project=pet-circle-app \
  --platforms=android,ios,macos,web \
  --android-package-name=com.example.pet_circle \
  --ios-bundle-id=com.example.petCircle \
  --macos-bundle-id=com.example.petCircle
```

Deploy Firestore rules and indexes with:

```bash
firebase deploy --only firestore --project pet-circle-app
```

Cloud Functions require Node 20 and are deployed separately:

```bash
npm --prefix functions ci
npm --prefix functions run deploy
```

Functions read `RESEND_API_KEY` (a Firebase secret), plus `FROM_EMAIL` and `APP_URL`
(see `functions/.env.example`). Both env vars fall back to defaults and log a warning when
unset — `FROM_EMAIL` falls back to Resend's shared sandbox sender, which **only delivers to
the Resend account owner**, so any environment that must reach real users has to set it to a
verified-domain sender.

## Notification Scope

Notifications are delivered on two paths, both live:

- **Firestore-backed in-app notifications** at `users/{uid}/notifications`, rendered in the
  notifications drawer. The settings toggle controls whether reminders and care updates appear
  in the app.
- **Firebase Cloud Messaging push**, sent from Cloud Functions via `sendPushToUser`
  (`functions/src/fcm-utils.ts`), which reads device tokens from `users/{uid}/fcmTokens` and
  prunes stale ones. Server-side event fanout, not client-only writes.

Server-generated notifications carry `titleKey` / `bodyKey` / `args` alongside frozen English
text, so the in-app row is localized at render time by `lib/utils/notification_localizer.dart`.
The Cloud Function also puts the notification's Firestore document ID in the FCM `data` payload
so the client can mark a pushed notification read — see BUG-038.

**Known limitation:** a push banner rendered by the OS while the app is backgrounded is built
directly from the FCM payload with no Dart involved, so it stays English regardless of the
reader's locale. The foreground banner is localized. Closing the gap requires the function to
look up the recipient's locale from their user document and localize server-side.

## Next Firebase Priorities

1. Server-side locale resolution for push payloads, so background banners follow the reader's
   language (see the limitation above).
2. Additional push triggers — today only invite-accepted sends one. Candidates: SRR threshold
   alerts, measurements recorded by another circle member, medication ending.
3. A `tsc --noEmit` (and ideally lint) step for `functions/` in CI. The workflow currently runs
   Flutter jobs only, so TypeScript breakage in the functions codebase ships unnoticed.
4. `firebase_storage` for pet photo upload when image management becomes a product requirement.
5. Crashlytics after the next release candidate so production failures are visible before
   broader rollout.
6. Analytics after the team defines an event taxonomy and success metrics.
7. Remote Config only when feature flags or experiments are needed.

## Known Gaps

Found during the Phase 2 audit, deliberately not fixed in that pass:

- **Invitee-side decline is denied by the rules on both writes.** `vet_dashboard.dart`'s decline
  action calls `cancelInvitation`, which requires `invitedByUid == request.auth.uid` (false for
  the invitee) and also updates `pets/{petId}.pendingInvites`, which only the owner may write.
  The clean fix is a rules clause letting the invited email set `status: 'declined'`, plus a
  trigger that clears `pendingInvites` with the Admin SDK.
- **Invitation acceptance still needs the `canAcceptPendingInvite` pet-document exception**
  (BUG-019). Moving acceptance into a callable function would let that clause be deleted, and
  would be the natural place to maintain the invitee's `petIds`, which nothing does today.
- **`pets/{petId}/medications` has no rule**, so it falls through to the catch-all deny. The
  `PetService` medication methods targeting that path are dead; medications live at
  `users/{uid}/medications`.
- **`Reminder` fires no notification**, neither a scheduled local one nor a push.
- **`findUserByEmail` / `findVetByEmail` are denied in production** — the rules only allow
  `isSelf(userId)` reads on `users`. Both swallow the error and return `null`, so vet lookup
  silently degrades to "not found".
- **`emergencyAlerts` and the medication morning/evening times** persist to Firestore but drive
  no behaviour.
