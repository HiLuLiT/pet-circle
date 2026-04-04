# ADR-0001: Flutter as Cross-Platform Framework

**Date**: 2026-01-15
**Status**: accepted
**Deciders**: Project team

## Context

Pet Circle needs to run on iOS, Android, Web (Chrome), and macOS Desktop from a single codebase. The app is a health-monitoring tool with real-time data sync, charts, and responsive layouts — requiring high-fidelity UI across all targets.

## Decision

Use Flutter with Dart SDK ^3.10.4 as the cross-platform framework, targeting all four platforms from a single codebase.

## Alternatives Considered

### Alternative 1: React Native
- **Pros**: Large ecosystem, JavaScript talent pool, Expo for rapid prototyping
- **Cons**: Web support is secondary (react-native-web), macOS requires separate tooling, bridge overhead for native modules
- **Why not**: Web and macOS are first-class targets — Flutter treats all four equally

### Alternative 2: Kotlin Multiplatform Mobile (KMM)
- **Pros**: Native UI on each platform, shared business logic in Kotlin
- **Cons**: No shared UI layer (must write SwiftUI + Jetpack Compose + web separately), higher maintenance cost
- **Why not**: Quadruples the UI work; this project requires visual parity across platforms

### Alternative 3: Native iOS + Android (two codebases)
- **Pros**: Best platform integration, native performance
- **Cons**: Double development cost, no web/macOS, hard to keep UIs in sync
- **Why not**: Four platforms from one team is only feasible with a shared codebase

## Consequences

### Positive
- Single codebase for all four targets
- Hot reload accelerates development
- `kIsWeb` guards handle the few platform divergences cleanly
- Dart's sound null safety prevents common runtime errors

### Negative
- Flutter web uses CanvasKit (canvas rendering), which limits SEO and browser devtools inspection
- Some packages don't support all platforms (e.g., `flutter_local_notifications` has no web support)
- macOS desktop requires additional entitlements and window size management

### Risks
- Platform-specific bugs require conditional imports (mitigated by `AbstractReminderService` pattern — see ADR-0015)
