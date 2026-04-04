# ADR-0024: kEnableFirebase Compile-Time Feature Flag

**Date**: 2026-02-01
**Status**: accepted
**Deciders**: Project team

## Context

Developers need to work on UI without a Firebase project configured. Widget tests should run without Firebase dependencies. The app needs a clean way to switch between mock data and live Firestore.

## Decision

Use `const bool kEnableFirebase = true` in `main.dart` as a compile-time feature flag. When `false`, stores are seeded from `lib/data/mock_data.dart`, Firebase initialization is skipped, and auth guards use mock state.

## Alternatives Considered

### Alternative 1: Environment variables / --dart-define
- **Pros**: Build-time configuration without code changes
- **Cons**: Requires build system setup, less visible to developers reading code
- **Why not**: A `const` in `main.dart` is immediately visible and toggleable; `--dart-define` is a future optimization

### Alternative 2: Feature flag service (LaunchDarkly, Firebase Remote Config)
- **Pros**: Runtime toggling, A/B testing
- **Cons**: External service dependency, overkill for a dev/prod toggle
- **Why not**: This flag controls dev workflow, not user-facing features

### Alternative 3: Separate app flavors
- **Pros**: Clean separation of dev and prod builds
- **Cons**: Requires flavor configuration per platform, more complex CI/CD
- **Why not**: A single flag is simpler for a small team

## Consequences

### Positive
- `const` enables tree-shaking — production builds exclude mock-mode code paths
- UI development possible without Firebase credentials
- Widget tests work without Firebase setup
- Mock data provides realistic seed data for all 7 stores

### Negative
- Manual toggle requires code change and rebuild
- Risk of accidentally shipping with `false`

### Risks
- Shipping with `kEnableFirebase = false` (mitigated by CI checks and code review)
