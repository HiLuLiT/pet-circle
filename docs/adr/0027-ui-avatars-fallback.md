# ADR-0027: UI Avatars API for User Avatar Fallback

**Date**: 2026-02-15
**Status**: accepted
**Deciders**: Project team

## Context

Users without profile photos (email/password sign-up, or when Google/Apple doesn't provide one) need a visual avatar. The app should show a meaningful fallback rather than a blank circle.

## Decision

Use `https://ui-avatars.com/api/?name=...` as a fallback for auto-generated letter-based avatars when `photoUrl` is null or empty.

## Alternatives Considered

### Alternative 1: Material CircleAvatar with initials (local)
- **Pros**: No external dependency, works offline
- **Cons**: Requires custom styling, less consistent appearance
- **Why not**: UI Avatars provides consistent, branded avatars with minimal code

### Alternative 2: Firebase Storage profile photos
- **Pros**: User-uploaded photos
- **Cons**: Firebase Storage deferred (ADR-0026)
- **Why not**: No upload infrastructure yet

## Consequences

### Positive
- Consistent, colorful avatars from initials
- Zero local implementation effort
- Graceful fallback when no photo URL exists

### Negative
- External API dependency (ui-avatars.com)
- No offline fallback for the fallback itself

### Risks
- UI Avatars service downtime (mitigated: low-criticality — avatar is decorative)
