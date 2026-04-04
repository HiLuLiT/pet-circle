# ADR-0019: Responsive Navigation (BottomNavBar vs. NavigationRail)

**Date**: 2026-03-20
**Status**: accepted
**Deciders**: Project team

## Context

The app targets phones (iOS/Android), tablets, web browsers, and macOS desktop. A bottom navigation bar is unusable at large screen widths. The layout must adapt across three breakpoints.

## Decision

Three breakpoints: mobile (<960px) uses `BottomNavigationBar`, tablet (960-1199px) and desktop (>=1200px) use `NavigationRail` in a `Row` layout. `IndexedStack` preserves all tab state.

## Alternatives Considered

### Alternative 1: Always bottom nav
- **Pros**: Consistent across all sizes, simple
- **Cons**: Wastes space on wide screens, looks wrong on desktop
- **Why not**: Desktop/tablet users expect side navigation

### Alternative 2: Navigation drawer (hamburger menu)
- **Pros**: Works at all sizes, familiar on web
- **Cons**: Hides navigation behind a tap, less discoverable
- **Why not**: `NavigationRail` keeps all tabs visible without hiding behind a menu

### Alternative 3: Separate tablet/desktop layout
- **Pros**: Fully optimized per form factor
- **Cons**: Multiple layouts to maintain, divergent UX
- **Why not**: `NavigationRail` + responsive breakpoints handle all sizes with one layout strategy

## Consequences

### Positive
- Natural adaptation from phone to desktop
- `NavigationRail` is Material 3's recommended adaptive pattern
- macOS minimum window 800x600 ensures rail path is always active
- Tab state preserved across navigation via `IndexedStack`

### Negative
- Three breakpoints to test (phone, tablet, desktop)
- `NavigationRail` labels may need truncation at narrow tablet widths

### Risks
- Breakpoint edge cases (mitigated by `ResponsiveUtils` centralizing breakpoint logic)
