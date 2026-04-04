# ADR-0004: GoRouter for Declarative URL-Based Navigation

**Date**: 2026-03-15
**Status**: accepted
**Deciders**: Project team

## Context

The app targets web (browser address bar) and native platforms with deep linking. The auth flow has multiple states (unauthenticated, needs verification, needs role, needs onboarding, authenticated) that must redirect correctly. The previous imperative Navigator 1.0 approach couldn't handle URL-based routing.

## Decision

Use `go_router ^14.8.1` with URL-based routes, a `redirect` guard for auth protection, and shell routes for the tab layout. Route constants are centralized in `AppRoutes`.

## Alternatives Considered

### Alternative 1: Navigator 2.0 (manual)
- **Pros**: No package dependency, full control
- **Cons**: Extremely verbose, complex `RouterDelegate` implementation, error-prone
- **Why not**: GoRouter wraps Navigator 2.0 with a declarative API that eliminates boilerplate

### Alternative 2: auto_route
- **Pros**: Code generation, type-safe routes, nested navigation
- **Cons**: Requires build_runner, generated code adds complexity
- **Why not**: GoRouter achieves the same with less setup and no code generation

### Alternative 3: Keep Navigator 1.0 (push/pop)
- **Pros**: Simple, familiar
- **Cons**: No URL support on web, no declarative redirects, no deep linking
- **Why not**: Web platform requires URL-based navigation for bookmarking and browser back/forward

## Consequences

### Positive
- URL-based navigation essential for web (browser address bar works)
- `redirect` function cleanly handles the 6-state auth machine
- Shell routes (`/shell/:role`) encode user role in URL for bookmarkable tab states
- `refreshListenable` wired to `authProvider` so redirects re-evaluate on auth changes
- Deep link routes (`/invite?token=XYZ`) integrate naturally

### Negative
- GoRouter version upgrades occasionally have breaking API changes
- Shell route nesting can be complex to debug
- URL parameters are strings (no type safety without manual parsing)

### Risks
- Web routing edge cases (tab URL params not syncing with shell state) require careful testing
