# ADR-0032: PlatformCapabilities Abstraction

**Date**: 2026-03-20
**Status**: accepted
**Deciders**: Project team

## Context

Platform-specific behavior (file system access, share functionality, notification support) was checked via scattered `if (kIsWeb)` conditions throughout the codebase. This made platform divergence hard to track and test.

## Decision

Centralize platform capability checks in a `PlatformCapabilities` utility class. Use conditional imports (`if (dart.library.html)`) for platform-specific implementations like CSV export.

## Alternatives Considered

### Alternative 1: Inline kIsWeb checks everywhere
- **Pros**: No abstraction layer
- **Cons**: Scattered, hard to audit, easy to miss a check
- **Why not**: Centralizing makes platform differences explicit and testable

### Alternative 2: Platform-specific packages only (no abstraction)
- **Pros**: Each package handles its own platform support
- **Cons**: Inconsistent APIs, no single source of truth for capabilities
- **Why not**: The app needs a unified way to query what's available

## Consequences

### Positive
- Single source of truth for platform capabilities
- Conditional imports prevent web build failures from native packages
- Pattern is reusable (reminder service, deep links, CSV export all follow it)

### Negative
- Adds an abstraction layer
- Conditional imports require stub files per platform-specific service

### Risks
- None significant — this is a well-established Flutter pattern
