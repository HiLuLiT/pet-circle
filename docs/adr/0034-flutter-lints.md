# ADR-0034: flutter_lints Default Ruleset

**Date**: 2026-01-15
**Status**: accepted
**Deciders**: Project team

## Context

The project needs a linting configuration to enforce code quality and catch common mistakes. Flutter provides an official lint package, but stricter alternatives exist.

## Decision

Use `flutter_lints ^6.0.0` with the default `flutter.yaml` ruleset. No custom rules added or removed.

## Alternatives Considered

### Alternative 1: very_good_analysis
- **Pros**: Stricter rules, catches more issues, used by Very Good Ventures
- **Cons**: More restrictive, may generate many warnings initially
- **Why not**: The default ruleset provides sufficient quality enforcement; stricter rules can be adopted later

### Alternative 2: Custom ruleset
- **Pros**: Tailored to project needs
- **Cons**: Maintenance burden, subjective choices
- **Why not**: The default covers the important cases without maintenance overhead

## Consequences

### Positive
- Official Flutter team maintenance
- Zero configuration
- `flutter analyze` produces clean output (commit `ef2546a` resolved all warnings)

### Negative
- Less strict than alternatives — some issues may not be caught

### Risks
- None significant — stricter rules can be adopted incrementally
