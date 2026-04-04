# ADR-0005: 3-Layer Design Token Architecture

**Date**: 2026-03-20
**Status**: accepted
**Deciders**: Project team

## Context

The original design system had all tokens in a single `app_theme.dart` file (~6 classes). The Figma designs were overhauled with new colors, fonts, and components. A migration was needed that could run incrementally (old and new tokens coexisting) and support dark mode.

## Decision

Adopt a three-layer design token system:
1. **Primitives** (`lib/theme/tokens/`) — raw hex values, font sizes, spacing scales
2. **Semantic** (`lib/theme/semantic/`) — role-mapped tokens as `ThemeExtension` (light + dark)
3. **Theme wiring** (`lib/theme/app_theme.dart`) — connects everything to Flutter `ThemeData`

## Alternatives Considered

### Alternative 1: Single flat AppTheme class
- **Pros**: Simple, everything in one place
- **Cons**: No separation of concerns, dark mode requires duplicating every value, large file
- **Why not**: The original approach; didn't scale to dark mode or incremental migration

### Alternative 2: Material 3 dynamic color only
- **Pros**: Built into Flutter, automatic dark mode
- **Cons**: Limited to Material color roles, can't express custom brand tokens (Ink, Sky categories)
- **Why not**: The Figma design system has 7 color categories with 5 scales each — far beyond Material 3's role set

### Alternative 3: Third-party design system package (e.g., Tailwind-style)
- **Pros**: Pre-built token architecture
- **Cons**: Flutter doesn't have a dominant design-token package; adds dependency
- **Why not**: Custom tokens mapped to Figma are more maintainable than adapting a generic system

## Consequences

### Positive
- Dark mode support without touching widget code (swap semantic layer only)
- `ThemeExtension` pattern enables `AppSemanticColors.of(context)` context-aware access
- Incremental migration: old and new extensions coexisted during transition
- Each token file stays under 200 lines (one concern per file)
- Figma-to-code mapping is explicit in `docs/design-system-migration.md`

### Negative
- Three layers add indirection (primitive → semantic → widget)
- Developers must use semantic tokens, never primitives directly in widgets
- Migration required touching 117 color call sites, 286 text style refs across 43 files

### Risks
- Token drift from Figma (mitigated by CLAUDE.md rules enforcing the Figma-to-code workflow)
