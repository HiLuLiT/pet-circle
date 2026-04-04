# ADR-0012: Firestore Care Circle Schema (Map + memberUids Array)

**Date**: 2026-03-10
**Status**: accepted
**Deciders**: Project team

## Context

Pet documents need to store care circle membership (which users have access, with what role). The primary query is "fetch all pets for a given user UID." Firestore cannot query into array-of-objects by a sub-field.

## Decision

Store care circle as a Firestore map keyed by user UID (`careCircle[uid] = {role, name, avatarUrl}`) with a parallel `memberUids` array for `arrayContains` queries.

## Alternatives Considered

### Alternative 1: Care circle as a subcollection
- **Pros**: Clean separation, each member is its own document
- **Cons**: Cannot query "all pets where user X is a member" without a collection group query; requires extra reads
- **Why not**: `arrayContains` on the pet document is simpler and cheaper

### Alternative 2: Separate pet_members collection
- **Pros**: Normalized, easy to query from both directions
- **Cons**: Extra collection to maintain, no atomic updates with pet data
- **Why not**: Denormalization on the pet document keeps reads efficient and atomic

### Alternative 3: Array of objects (no map)
- **Pros**: Simpler structure
- **Cons**: Firestore can't query `arrayContains` on a sub-field of an object in an array
- **Why not**: The UID-keyed map enables O(1) role lookup; the parallel `memberUids` array enables the primary query

## Consequences

### Positive
- `pets.where('memberUids', arrayContains: uid)` is the primary query — fast and indexed
- `careCircle[uid].role` enables O(1) role lookup in security rules
- Atomic updates: care circle changes are part of the pet document write

### Negative
- `memberUids` must stay in sync with `careCircle` keys (enforced in rules and service writes)
- Pet document size grows with members (acceptable for care circles of 5-10 people)
- Denormalized data (member name/avatar) can become stale

### Risks
- Sync drift between `memberUids` and `careCircle` (mitigated by Firestore security rules that validate both are updated together)
