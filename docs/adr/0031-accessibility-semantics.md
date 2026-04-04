# ADR-0031: Explicit Semantics Labels + RTL Alignment

**Date**: 2026-03-25
**Status**: accepted
**Deciders**: Project team

## Context

The app supports Hebrew (RTL) and must be accessible to visually impaired users. Flutter's Material widgets provide some default semantics, but custom widgets need explicit labels for screen readers.

## Decision

Add explicit `Semantics` labels to all interactive widgets. Fix RTL alignment for Hebrew locale. Include accessibility tests in the test suite.

## Alternatives Considered

### Alternative 1: Rely on Material widget semantics only
- **Pros**: Less code, automatic for standard widgets
- **Cons**: Custom widgets (NeumorphicCard, TogglePill, etc.) have no semantic labels
- **Why not**: Custom widgets are a significant portion of the UI

### Alternative 2: Ignore RTL in v1
- **Pros**: Simpler layout code
- **Cons**: Hebrew users get broken layouts
- **Why not**: Hebrew is a core supported locale (ADR-0017)

## Consequences

### Positive
- Screen readers can describe all interactive elements
- RTL layouts work correctly for Hebrew users
- Accessibility tests catch regressions

### Negative
- Additional `Semantics` widgets increase widget tree depth
- RTL testing requires locale-aware test setup

### Risks
- New widgets added without semantics (mitigated by accessibility test suite)
