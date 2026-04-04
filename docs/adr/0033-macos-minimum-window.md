# ADR-0033: macOS Minimum Window Size (800x600)

**Date**: 2026-03-20
**Status**: accepted
**Deciders**: Project team

## Context

The app runs on macOS desktop. Without a minimum window size, users can resize the window to dimensions that break the layout (especially the 5-tab navigation and responsive breakpoints).

## Decision

Enforce a minimum macOS window size of 800x600 pixels. At this width, the `NavigationRail` is always active (responsive breakpoint is 960px, but 800px provides a safe minimum).

## Alternatives Considered

### Alternative 1: No minimum size
- **Pros**: Maximum user flexibility
- **Cons**: Layout breaks at small sizes, poor UX
- **Why not**: Broken layouts are worse than constrained window sizing

### Alternative 2: Fixed window size (non-resizable)
- **Pros**: Guaranteed layout, no responsive logic needed
- **Cons**: Users expect resizable windows on macOS
- **Why not**: Resizing is a fundamental macOS UX expectation

## Consequences

### Positive
- Layout never breaks from window sizing
- NavigationRail always has enough space

### Negative
- Constraint may feel restrictive on very small displays

### Risks
- None significant
