# ADR-0008: Flat Shadows Replacing Neumorphism

**Date**: 2026-03-20
**Status**: accepted
**Deciders**: Project team (Figma design system)

## Context

The original app used a neumorphic dual-shadow system (`neumorphicOuter` + `neumorphicInner`) for cards and containers. The Figma v2 design system removed neumorphism entirely in favor of subtle flat shadows.

## Decision

Replace neumorphic shadows with three flat elevation levels: `Shadow/Small` (cards), `Shadow/Medium` (elevated elements), `Shadow/Large` (modals/overlays).

## Alternatives Considered

### Alternative 1: Keep neumorphic shadows
- **Pros**: Distinctive visual identity, depth illusion
- **Cons**: Doesn't match new Figma designs, neumorphism has fallen out of trend, harder to implement consistently across themes
- **Why not**: Figma v2 explicitly removed all neumorphic elements

### Alternative 2: Material 3 elevation system
- **Pros**: Built-in, consistent with Material guidelines
- **Cons**: Uses tonal elevation (color overlay) which conflicts with the custom color system
- **Why not**: Custom shadow tokens give precise control matching Figma specs

### Alternative 3: No shadows (fully flat)
- **Pros**: Simplest implementation, clean aesthetic
- **Cons**: Loses visual hierarchy between layers
- **Why not**: Figma designs use subtle shadows for depth; fully flat loses important UI affordances

## Consequences

### Positive
- Simpler shadow implementation (single `BoxShadow` vs. dual neumorphic)
- Better dark mode support (neumorphic shadows are hard to adapt)
- Consistent with modern design trends
- `NeumorphicCard` widget name preserved but implementation simplified

### Negative
- Loss of the distinctive neumorphic visual identity
- Required updating all card and container widgets

### Risks
- None significant — flat shadows are strictly simpler to maintain
