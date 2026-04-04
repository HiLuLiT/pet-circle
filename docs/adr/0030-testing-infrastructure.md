# ADR-0030: flutter_test with Shared Helpers (80% Coverage Target)

**Date**: 2026-03-15
**Status**: accepted
**Deciders**: Project team

## Context

The app needs a testing strategy that works with the singleton store architecture and `kEnableFirebase` feature flag. The team targets 80% line coverage.

## Decision

Use Flutter's built-in `flutter_test` with shared helpers in `test/helpers/` (`test_app.dart`, `mock_stores.dart`, `test_http_overrides.dart`). Test directory mirrors `lib/` structure. Coverage target: 80%.

## Alternatives Considered

### Alternative 1: mockito + code generation
- **Pros**: Type-safe mocks, widely used
- **Cons**: Requires `build_runner`, generated code for every mocked class
- **Why not**: Singleton stores with `kEnableFirebase = false` make mocking unnecessary — stores work from mock data directly

### Alternative 2: Integration tests only
- **Pros**: Tests real user flows end-to-end
- **Cons**: Slow, flaky, hard to debug, poor coverage of edge cases
- **Why not**: Widget and unit tests provide faster feedback and better coverage

### Alternative 3: No tests (MVP skip)
- **Pros**: Faster initial development
- **Cons**: Technical debt, regression risk, harder to refactor
- **Why not**: The project explicitly targets 80% coverage in CLAUDE.md

## Consequences

### Positive
- No mock framework dependency — `kEnableFirebase = false` seeds all stores
- Shared `testApp()` wrapper eliminates per-test boilerplate
- Test directory mirrors source for easy navigation
- TDD workflow enforced by project conventions

### Negative
- Shared test helpers must be maintained alongside source changes
- No compile-time mock type safety (unlike mockito)

### Risks
- Coverage regression during rapid development (mitigated by CI coverage checks)
