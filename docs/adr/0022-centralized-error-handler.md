# ADR-0022: Centralized AppErrorHandler with Crashlytics

**Date**: 2026-03-25
**Status**: accepted
**Deciders**: Project team

## Context

Unhandled exceptions in Flutter can crash the app silently. The app needs a centralized way to capture, report, and display errors across all layers (framework, platform, business logic).

## Decision

Use `AppErrorHandler` singleton that wires `FlutterError.onError` and `PlatformDispatcher.instance.onError` before `runApp`. All caught errors are forwarded to Firebase Crashlytics when `kEnableFirebase = true`. UI errors use `SnackBar`.

## Alternatives Considered

### Alternative 1: Per-widget try/catch only
- **Pros**: Localized error handling
- **Cons**: Misses unhandled framework and platform errors, inconsistent error reporting
- **Why not**: Doesn't catch the widest error surface

### Alternative 2: Sentry
- **Pros**: Platform-agnostic, rich error context, performance monitoring
- **Cons**: Additional third-party service, separate from Firebase ecosystem
- **Why not**: Crashlytics is included in the Firebase suite already adopted (ADR-0002)

### Alternative 3: runZonedGuarded wrapper
- **Pros**: Catches all async errors in the zone
- **Cons**: Doesn't catch Flutter framework errors (`FlutterError.onError`)
- **Why not**: `AppErrorHandler` covers both framework and platform errors

## Consequences

### Positive
- Single `reportError` call site for all business logic errors
- Automatic crash reporting to Crashlytics in production
- Graceful degradation when `kEnableFirebase = false`

### Negative
- Crashlytics is Firebase-only (vendor lock-in)
- Error handler must be initialized before `runApp`

### Risks
- Errors in the error handler itself (mitigated by keeping the handler minimal)
