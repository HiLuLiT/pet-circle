# ADR-0003: ChangeNotifier Global Singleton Stores

**Date**: 2026-03-01
**Status**: accepted
**Deciders**: Project team

## Context

The app needs a state management approach for 7 domain stores (pets, measurements, medications, notes, notifications, user, settings) that receive real-time Firestore streams and expose data to widgets across the entire widget tree.

## Decision

Use plain `ChangeNotifier` stores exposed as top-level Dart singletons (e.g., `final petStore = PetStore()`), consumed in widgets via `ListenableBuilder`.

## Alternatives Considered

### Alternative 1: Riverpod
- **Pros**: Compile-safe, auto-dispose, testable via overrides, no global state
- **Cons**: Boilerplate for providers + families, learning curve, code generation in v2
- **Why not**: Overkill for 7 well-defined stores with clear lifecycles; singletons are simpler

### Alternative 2: Bloc/Cubit
- **Pros**: Structured event/state separation, good tooling (bloc_test), widely adopted
- **Cons**: Significant boilerplate (events, states, blocs), verbose for simple CRUD
- **Why not**: Event/state separation adds unnecessary indirection for Firestore stream-based stores

### Alternative 3: Provider package
- **Pros**: Standard Flutter recommendation, widget-tree scoped, lazy initialization
- **Cons**: Requires `MultiProvider` wrapper, `context.read`/`context.watch` can be error-prone
- **Why not**: Singleton pattern is simpler and avoids widget-tree injection entirely; stores need to be accessible from services too

## Consequences

### Positive
- Minimal boilerplate — each store is ~100-200 lines
- Stores are accessible from anywhere (services, other stores) without BuildContext
- `ListenableBuilder` provides granular rebuilds
- Easy to test: set `kEnableFirebase = false` and stores work from mock data
- `ValueNotifier` handles two simple app-wide values (locale, dark mode) separately

### Negative
- Global singletons make dependency injection harder
- No automatic disposal — stores live for the app lifetime
- Must manually call `notifyListeners()` after every mutation
- No compile-time safety for missing listeners (easy to forget `ListenableBuilder`)

### Risks
- Store interdependencies could create update cascades (mitigated by keeping stores independent with clear subscription boundaries)
