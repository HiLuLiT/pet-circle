# ADR-0025: Static Breed List (No API Dependency)

**Date**: 2026-01-17
**Status**: accepted
**Deciders**: Project team

## Context

Onboarding requires users to select their dog's breed. The initial implementation fetched breeds from the Dog CEO API at runtime. This added a network dependency to every onboarding session.

## Decision

Hardcode 148 dog breeds as `const allBreeds = [...]` in `breed_search_field.dart`. Use client-side live filtering on keypress. The breed list was sourced from the Dog CEO API once and frozen.

## Alternatives Considered

### Alternative 1: Dog CEO API (runtime fetch)
- **Pros**: Always up-to-date, comprehensive
- **Cons**: Network dependency on every onboarding, API rate limits, latency
- **Why not**: Explicitly reversed — commit message: "Use hardcoded breed list from Dog CEO API instead of fetching"

### Alternative 2: Server-side breed list (Firestore)
- **Pros**: Updatable without app release
- **Cons**: Extra Firestore reads, requires collection management
- **Why not**: Dog breeds don't change frequently enough to justify dynamic loading

## Consequences

### Positive
- Zero network dependency during onboarding
- Instant search/filter with no loading state
- Works offline
- No API rate limits

### Negative
- Breed list must be manually updated if new breeds are added
- 148 breeds hardcoded in source code (adds ~3KB)

### Risks
- Stale breed list (mitigated: AKC breed list changes rarely, easily updated in a patch)
