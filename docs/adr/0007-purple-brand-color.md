# ADR-0007: Purple Brand Color (#6B4EFF)

**Date**: 2026-03-20
**Status**: accepted
**Deciders**: Project team (Figma design system)

## Context

The original app used a warm chocolate/brown palette (`#402A24`) as the primary brand color with pink and cherry accents. The Figma v2 design system introduced a completely new color identity.

## Decision

Adopt `Primary/Base = #6B4EFF` (purple) as the primary brand color, with a 7-category palette: Ink (grays), Sky (backgrounds), Primary (purple), Red, Green, Yellow, Blue — each with 5 scales (Lightest, Lighter, Light, Base, Dark/Darkest).

## Alternatives Considered

### Alternative 1: Keep warm chocolate palette
- **Pros**: No migration effort, existing brand recognition
- **Cons**: Doesn't match the new Figma designs, feels dated
- **Why not**: Design system overhaul required a fresh visual identity

### Alternative 2: Material 3 dynamic color (seed-based)
- **Pros**: Automatic palette generation from a single seed color
- **Cons**: Limited control over exact shades, can't express 7 semantic categories
- **Why not**: The Figma design specifies exact hex values for all 35+ color tokens

## Consequences

### Positive
- Modern, vibrant visual identity
- 7-category palette covers all UI states (success, error, warning, info)
- Each category has consistent 5-scale gradation for flexibility
- CLAUDE.md enforces: "NEVER hardcode the old color values"

### Negative
- Required migrating 117 color call sites across 43 files
- Old screenshots and documentation became outdated
- Users familiar with the old brand may need adjustment

### Risks
- Color accessibility (contrast ratios) must be validated for all text/background combinations
