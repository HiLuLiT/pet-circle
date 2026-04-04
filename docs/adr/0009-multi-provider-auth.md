# ADR-0009: Multi-Provider Authentication (Email + Google + Apple)

**Date**: 2026-01-20
**Status**: accepted
**Deciders**: Project team

## Context

The app needs to support sign-up and sign-in across iOS, Android, web, and macOS. App Store Review Guidelines require Apple Sign-In when any social sign-in is offered on iOS/macOS.

## Decision

Support three sign-in methods: email/password (with email verification and password reset), Google Sign-In (`google_sign_in`), and Sign in with Apple (`sign_in_with_apple`). Apple Sign-In shows on all platforms with a web fallback snackbar.

## Alternatives Considered

### Alternative 1: Email/password only
- **Pros**: Simplest implementation, no third-party SDK
- **Cons**: Higher friction sign-up, no social graph integration
- **Why not**: Social sign-in significantly reduces sign-up abandonment

### Alternative 2: Phone number authentication
- **Pros**: No password to remember, universal
- **Cons**: Requires SMS costs, not available in all countries, Firebase phone auth has per-SMS pricing
- **Why not**: Email + social covers the target audience; phone auth adds cost and complexity

### Alternative 3: Magic link (passwordless email)
- **Pros**: No password, secure
- **Cons**: Requires email app switching (poor mobile UX), Firebase Dynamic Links deprecated
- **Why not**: Traditional email/password with optional social sign-in is more familiar to users

## Consequences

### Positive
- Compliant with App Store review requirements (Apple Sign-In present)
- Google Sign-In covers Android and web users seamlessly
- Email/password provides a universal fallback
- `AuthService` abstracts platform differences (popup vs. native SDK)

### Negative
- Three auth providers to maintain and test
- Apple Sign-In requires Apple Developer account configuration
- Web Apple Sign-In requires additional server-side setup

### Risks
- Platform-specific auth failures (mitigated by graceful error handling and fallback to email/password)
