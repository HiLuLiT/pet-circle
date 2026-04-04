# ADR-0016: app_links for Native Deep Links

**Date**: 2026-03-15
**Status**: accepted
**Deciders**: Project team

## Context

The invitation system uses deep links (`/invite?token=XYZ`). Native platforms need to intercept these URLs and route them to the app. On web, GoRouter handles URLs directly from the browser address bar.

## Decision

Use `app_links ^6.3.3` for native platform deep link interception, with a conditional import stub so web builds compile without the native package.

## Alternatives Considered

### Alternative 1: Firebase Dynamic Links
- **Pros**: Deferred deep linking (pre-install attribution), analytics
- **Cons**: Deprecated by Google
- **Why not**: Building on a deprecated service

### Alternative 2: uni_links (predecessor)
- **Pros**: Established package
- **Cons**: Deprecated in favor of `app_links`, no longer maintained
- **Why not**: `app_links` is the official successor

## Consequences

### Positive
- Supports both custom URI schemes and HTTPS universal links
- Conditional import pattern prevents web build failures
- GoRouter integration routes deep links through the same redirect logic

### Negative
- Requires platform-specific configuration (iOS Associated Domains, Android intent filters)
- Conditional imports add a stub file per platform-specific service

### Risks
- Deep link misconfiguration on specific platforms (mitigated by testing on each target)
