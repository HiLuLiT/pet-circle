# ADR-0018: ValueNotifier Dark Mode

**Date**: 2026-02-20
**Status**: accepted
**Deciders**: Project team

## Context

The app needs a dark mode toggle that persists across sessions. The theme must switch instantly without app restart, and both light and dark themes must use the semantic token system.

## Decision

Control dark mode via a global `ValueNotifier<bool> appDarkMode` in `main.dart`. `MaterialApp.router` rebuilds via `ValueListenableBuilder`. Theme toggles between `buildAppTheme()` and `buildDarkTheme()`, both using `AppSemanticColors` ThemeExtension.

## Alternatives Considered

### Alternative 1: adaptive_theme package
- **Pros**: Persistent theme, system-following mode, simple API
- **Cons**: Extra dependency for a simple toggle
- **Why not**: `ValueNotifier` achieves the same with zero dependencies

### Alternative 2: ThemeMode.system (system-following only)
- **Pros**: Automatic, follows OS setting
- **Cons**: No user override, no manual toggle
- **Why not**: Users should be able to override the system setting

## Consequences

### Positive
- Zero-dependency implementation
- Instant theme switching without restart
- `AppSemanticColors.of(context)` returns correct values in both themes
- User preference persists via `settingsStore` / Firestore

### Negative
- Global `ValueNotifier` is not scoped to the widget tree
- Two theme builders to maintain (`buildAppTheme` + `buildDarkTheme`)

### Risks
- Theme-unaware widgets may use hardcoded colors (mitigated by CLAUDE.md rule: "NEVER hardcode hex colors")
