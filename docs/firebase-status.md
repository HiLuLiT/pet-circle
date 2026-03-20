# Firebase Status

## Supported Now

- Firebase Auth is wired for email/password, Google, and Apple sign-in.
- Firestore is the source of truth for users, pets, measurements, notes, medications, invitations, settings, and in-app notifications.
- Invitation acceptance now requires a trusted `pendingInvites` entry on the pet document, so pet access is no longer granted by a broad self-join rule.
- Android now applies the Google Services Gradle plugin, and the repo includes a default Firebase project alias in `.firebaserc`.
- Repo-managed Firestore rules are deployed to the default Firebase project (`pet-circle-app`).

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

Deploy Firestore rules with:

```bash
firebase deploy --only firestore:rules --project pet-circle-app
```

## Notification Scope

The current supported notification model is **Firestore-backed in-app notifications**.

- The settings toggle controls whether reminders and care updates should appear inside the app.
- Firebase Cloud Messaging is intentionally deferred until the app has device token registration, background handlers, and a backend sender.
- Any future FCM work should be paired with server-side event fanout rather than client-only writes.

## Next Firebase Priorities

1. `functions` or another trusted backend path for invitation email delivery and server-generated notifications.
2. `firebase_storage` for pet photo upload when image management becomes a product requirement.
3. Crashlytics after the next release candidate so production failures are visible before broader rollout.
4. Analytics after the team defines an event taxonomy and success metrics.
5. Remote Config only when feature flags or experiments are needed.
