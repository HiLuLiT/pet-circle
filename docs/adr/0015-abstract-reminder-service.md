# ADR-0015: Abstract Service Pattern for Platform Abstraction

**Date**: 2026-03-15
**Status**: accepted
**Deciders**: Project team

## Context

`flutter_local_notifications` doesn't support web. The app needs medication reminder notifications on native platforms while compiling and running on web without errors.

## Decision

Use an `AbstractReminderService` interface with two implementations: `ReminderService` (native: iOS/Android/macOS) and `WebReminderService` (no-op stubs). Selected at startup via `kIsWeb` check in `main.dart`.

## Alternatives Considered

### Alternative 1: Platform #if preprocessor guards
- **Pros**: Compile-time platform exclusion
- **Cons**: Dart doesn't have C-style preprocessor; conditional imports are the equivalent but scattered
- **Why not**: Abstract service centralizes the platform split in one place

### Alternative 2: Single service with if (kIsWeb) branches
- **Pros**: One file, simple
- **Cons**: Web build still imports the native package (may fail), cluttered code
- **Why not**: Conditional imports + abstract interface cleanly separates platform code

### Alternative 3: Firebase Cloud Messaging for all platforms
- **Pros**: Cross-platform push notifications including web
- **Cons**: Requires server-side sender, device token management, background handlers
- **Why not**: FCM is explicitly deferred per `firebase-status.md` until server infrastructure exists

## Consequences

### Positive
- Clean interface — callers don't know which platform implementation they're using
- Web builds compile without importing `flutter_local_notifications`
- Pattern is reusable for other platform-divergent features (e.g., `DeepLinkService`, CSV export)

### Negative
- Two implementations to maintain
- Web users get no notification functionality (silent no-op)

### Risks
- None significant — the pattern is well-established in Flutter
