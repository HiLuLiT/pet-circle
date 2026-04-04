# ADR-0006: Instrument Sans Typography

**Date**: 2026-03-20
**Status**: accepted
**Deciders**: Project team (Figma design system)

## Context

The original app used Inter as its primary font. The Figma design system v2 specified a new font: Instrument Sans (variable font with width axis). The font needed to work across all four platforms.

## Decision

Use Instrument Sans as the primary font family, loaded via `google_fonts ^6.2.1` with `fontVariationSettings: "'wdth' 100"`. An offline fallback is added for macOS where network font fetching may fail.

## Alternatives Considered

### Alternative 1: Keep Inter
- **Pros**: Already integrated, widely available, excellent readability
- **Cons**: Doesn't match the new Figma designs
- **Why not**: Design system mandates Instrument Sans for visual parity with Figma

### Alternative 2: Bundle static font files
- **Pros**: No network dependency, faster first render
- **Cons**: Increases app bundle size, requires manual font file management
- **Why not**: `google_fonts` caches after first load; static bundling is a future optimization (noted as TODO)

### Alternative 3: System font (SF Pro on iOS, Roboto on Android)
- **Pros**: Zero configuration, native look
- **Cons**: Different font per platform breaks cross-platform visual parity
- **Why not**: The app requires identical appearance across all platforms

## Consequences

### Positive
- Exact visual match with Figma designs
- Variable font supports multiple weights without separate font files
- `google_fonts` handles caching automatically

### Negative
- First launch requires network to fetch font (fallback to system font)
- macOS may fail to fetch fonts in some network configurations
- Runtime font loading adds slight delay on first render

### Risks
- Network dependency for fonts (mitigated by offline fallback; TODO to bundle static files)
