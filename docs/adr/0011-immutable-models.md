# ADR-0011: Immutable Models with copyWith

**Date**: 2026-03-01
**Status**: accepted
**Deciders**: Project team

## Context

The app uses global singleton stores that expose data to many widgets simultaneously. Mutable models could lead to shared-state bugs where one widget's modification unexpectedly affects another.

## Decision

All models are immutable Dart classes with `const` constructors and `copyWith` methods. Serialization (`fromFirestore`/`toFirestore`) lives directly on the model class. No code generation.

## Alternatives Considered

### Alternative 1: Mutable models with setters
- **Pros**: Less boilerplate, familiar OOP pattern
- **Cons**: Shared-state bugs in singleton stores, harder to debug state changes
- **Why not**: Immutability prevents entire categories of bugs in a global-state architecture

### Alternative 2: freezed package (code generation)
- **Pros**: Auto-generated `copyWith`, `==`, `hashCode`, `toString`, JSON serialization
- **Cons**: Requires `build_runner`, generated files add noise, longer build times
- **Why not**: Hand-written `copyWith` is straightforward for the model count (~11 models); avoids build tooling complexity

### Alternative 3: json_serializable (code generation)
- **Pros**: Auto-generated `fromJson`/`toJson`
- **Cons**: Firestore uses `DocumentSnapshot`, not raw JSON; still need manual `fromFirestore` wrapper
- **Why not**: Direct Firestore serialization is simpler than an intermediate JSON layer

## Consequences

### Positive
- No shared-state mutation bugs
- `copyWith` enables clean state updates in stores
- Easy to test (construct, modify via `copyWith`, assert)
- No build_runner dependency

### Negative
- Manual `copyWith` methods must be updated when adding fields (easy to forget a field)
- More verbose than mutable classes
- No auto-generated `==` or `hashCode`

### Risks
- Forgotten fields in `copyWith` (mitigated by comprehensive unit tests for every model)
