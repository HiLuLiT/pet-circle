# ADR-0028: Firestore In-App Notifications (FCM Deferred)

**Date**: 2026-03-20
**Status**: accepted
**Deciders**: Project team

## Context

The app needs notifications for care circle events (invitations, measurements, medication reminders). Firebase Cloud Messaging (FCM) would provide cross-platform push notifications but requires server-side infrastructure.

## Decision

Store in-app notifications in Firestore (`users/{uid}/notifications` subcollection) synced via `notificationStore`. Use `flutter_local_notifications` for local medication reminders on native platforms. Defer FCM.

## Alternatives Considered

### Alternative 1: FCM from day one
- **Pros**: Real push notifications, background delivery
- **Cons**: Requires device token management, background handlers, server-side sender
- **Why not**: `firebase-status.md` explicitly defers FCM until server infrastructure exists

### Alternative 2: Third-party service (OneSignal, Pusher)
- **Pros**: Managed push infrastructure
- **Cons**: Additional vendor, cost, SDK integration
- **Why not**: Premature for MVP; Firestore-based notifications cover the immediate need

## Consequences

### Positive
- No server-side infrastructure needed
- In-app notifications sync in real-time via Firestore streams
- Local medication reminders work on native platforms

### Negative
- No push notifications when app is closed
- Web gets no notification capability (no-op stub)
- Firestore reads for every notification check

### Risks
- Users miss important notifications when app is backgrounded (acceptable for MVP; FCM is planned for future phase)
