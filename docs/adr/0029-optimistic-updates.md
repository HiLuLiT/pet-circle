# ADR-0029: Optimistic Updates with Rollback

**Date**: 2026-03-25
**Status**: accepted
**Deciders**: Project team

## Context

Firestore writes have network latency. Users measuring respiratory rates or adding medications expect instant feedback. The app needs to feel responsive even on slow connections.

## Decision

Stores apply mutations locally before awaiting the Firestore write. If the write fails, the store reverts to the previous state. A `_pendingDeletes` set prevents Firestore stream re-emissions from restoring deleted items during the async window.

## Alternatives Considered

### Alternative 1: Pessimistic updates (wait for Firestore)
- **Pros**: Always consistent, no rollback needed
- **Cons**: UI feels sluggish on slow connections, loading spinners everywhere
- **Why not**: Health monitoring UX demands instant feedback

### Alternative 2: No rollback (accept eventual inconsistency)
- **Pros**: Simpler implementation
- **Cons**: Failed writes leave UI in incorrect state
- **Why not**: Correctness matters for health data

### Alternative 3: CQRS-style command queue
- **Pros**: Full offline support, guaranteed delivery
- **Cons**: Massive complexity for a small app
- **Why not**: Overkill; Firestore's built-in offline persistence handles most cases

## Consequences

### Positive
- App feels instant on any connection speed
- Rollback ensures correctness after failed writes
- `_pendingDeletes` prevents ghost items reappearing

### Negative
- More complex store logic (save previous state, rollback on error)
- Brief inconsistency window between local mutation and Firestore confirmation

### Risks
- Race conditions between optimistic update and Firestore stream (mitigated by `_pendingDeletes` pattern)
