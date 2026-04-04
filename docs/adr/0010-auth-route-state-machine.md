# ADR-0010: 6-State Auth Route Machine

**Date**: 2026-04-01
**Status**: accepted
**Deciders**: Project team

## Context

The app has a multi-step onboarding flow: role selection, email verification, pet onboarding, then dashboard. A simple boolean `isAuthenticated` flag cannot express the intermediate states. Existing users who already completed onboarding must skip straight to the dashboard.

## Decision

Use a six-state `AuthRouteState` enum (`loading`, `unauthenticated`, `needsEmailVerification`, `needsRole`, `needsOnboarding`, `authenticated`) to drive GoRouter's redirect logic. Each state maps to a distinct screen.

## Alternatives Considered

### Alternative 1: Boolean isAuthenticated flag
- **Pros**: Simple, two states
- **Cons**: Cannot express email verification, role selection, or onboarding steps
- **Why not**: Five intermediate states exist between "not signed in" and "fully ready"

### Alternative 2: Separate Provider streams per state
- **Pros**: Fine-grained reactivity per condition
- **Cons**: Complex to coordinate; redirect logic scattered across multiple listeners
- **Why not**: A single enum with GoRouter's `redirect` is simpler and centralizes all routing logic

## Consequences

### Positive
- Every auth state maps to exactly one screen — no ambiguity
- GoRouter `redirect` re-evaluates on every auth state change via `refreshListenable`
- Backward compatibility: existing Firestore users without `hasCompletedOnboarding` default to `true`
- New users flow through the full onboarding pipeline

### Negative
- Adding a new auth state requires updating the enum, redirect logic, and router
- The `hasCompletedOnboarding` migration logic adds complexity to `fromFirestore`

### Risks
- State transitions must be exhaustive in redirect logic (mitigated by enum switch with no default case)
