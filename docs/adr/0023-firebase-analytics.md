# ADR-0023: Firebase Analytics with GoRouter Observer

**Date**: 2026-03-25
**Status**: accepted
**Deciders**: Project team

## Context

The app needs usage analytics to understand which features are used and how users navigate. The analytics solution must integrate with the existing Firebase backend and GoRouter navigation.

## Decision

Use `firebase_analytics` with `FirebaseAnalyticsObserver` wired into GoRouter's `observers` list for automatic screen view tracking.

## Alternatives Considered

### Alternative 1: Mixpanel / Amplitude
- **Pros**: More advanced funnels, A/B testing, cohort analysis
- **Cons**: Additional service, separate SDK, cost
- **Why not**: Firebase Analytics is free and already in the Firebase suite

### Alternative 2: No analytics
- **Pros**: Simplest, no privacy concerns
- **Cons**: No insight into user behavior
- **Why not**: Basic usage data is essential for product decisions

## Consequences

### Positive
- Zero-cost analytics included with Firebase
- Automatic screen view tracking via GoRouter observer
- Conditionally activated only when `kEnableFirebase = true`

### Negative
- Firebase Analytics has limited custom reporting compared to dedicated analytics platforms
- Data lives in Google ecosystem

### Risks
- None significant for current needs
