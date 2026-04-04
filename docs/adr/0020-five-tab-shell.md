# ADR-0020: 5-Tab IndexedStack Navigation Shell

**Date**: 2026-03-20
**Status**: accepted
**Deciders**: Project team (Figma design system)

## Context

The app needs a persistent tab-based navigation shell. The Figma v2 design system specified 5 tabs (Home, Trends, Diary, Measure, Medicine), expanding from the original 4 tabs. Settings and Notifications are accessed via overlays, not tabs.

## Decision

Use `IndexedStack` with 5 tabs matching the Figma tab bar component. Settings and Notifications are `DraggableScrollableSheet` overlays.

## Alternatives Considered

### Alternative 1: Keep 4 tabs (original)
- **Pros**: Fewer tabs, simpler
- **Cons**: Doesn't match Figma v2 designs, Diary feature has no home
- **Why not**: Figma v2 explicitly added the Diary tab

### Alternative 2: PageView with AutomaticKeepAliveClientMixin
- **Pros**: Swipe between tabs, lazy loading
- **Cons**: More complex state preservation, swipe conflicts with horizontal scroll content
- **Why not**: `IndexedStack` is simpler and preserves all tab state without keep-alive boilerplate

### Alternative 3: Separate routes per tab (no persistent state)
- **Pros**: Simpler routing
- **Cons**: Scroll position and form state lost on tab switch
- **Why not**: Users expect tab state to be preserved (e.g., scroll position on Trends)

## Consequences

### Positive
- All 5 tabs stay alive — scroll position and state preserved
- Matches Figma design exactly
- Settings/Notifications as overlays reduce tab count to 5 (manageable on phone)

### Negative
- All 5 tabs are built at shell initialization (memory cost)
- `IndexedStack` doesn't support lazy tab loading

### Risks
- Memory pressure from 5 simultaneous tab trees (acceptable for this app's complexity)
