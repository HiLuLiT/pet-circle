# ADR-0002: Firebase as Backend (Auth + Firestore)

**Date**: 2026-01-20
**Status**: accepted
**Deciders**: Project team

## Context

The app needs user authentication, real-time database sync (multiple users watching the same pet data), and crash reporting. The team is small and wants to avoid managing server infrastructure.

## Decision

Use Firebase as the full backend: Firebase Auth for identity, Cloud Firestore for the database, Firebase Crashlytics for crash reporting, and Firebase Analytics for usage events. No custom server.

## Alternatives Considered

### Alternative 1: Supabase (Postgres + Auth)
- **Pros**: SQL database, open source, row-level security, real-time subscriptions
- **Cons**: Smaller Flutter SDK ecosystem, fewer managed services (no Crashlytics equivalent)
- **Why not**: Firestore's document model aligns better with the care-circle sharing pattern; Firebase Auth has built-in Google + Apple sign-in

### Alternative 2: Custom REST API (Node/Django)
- **Pros**: Full control, SQL database, custom business logic
- **Cons**: Requires server hosting, DevOps, and maintenance; no built-in real-time sync
- **Why not**: Server management overhead is too high for a small team; real-time care circle updates would require WebSockets

### Alternative 3: AWS Amplify
- **Pros**: AWS ecosystem, AppSync for GraphQL, Cognito for auth
- **Cons**: More complex setup, steeper learning curve, Flutter SDK less mature than Firebase
- **Why not**: Firebase has better Flutter integration and simpler configuration

## Consequences

### Positive
- Zero server management
- Real-time Firestore streams enable live care circle data sharing
- Firebase Auth integrates directly with Google Sign-In and Apple Sign-In
- Crashlytics provides automatic crash reporting
- Incremental adoption: Cloud Functions and Storage explicitly deferred to future phases

### Negative
- Vendor lock-in to Google Cloud
- Firestore's NoSQL model requires denormalization (e.g., `memberUids` array for queries)
- No server-side business logic without Cloud Functions
- Firestore pricing is per-read/write, which can be expensive at scale

### Risks
- Security rules complexity grows with features (mitigated by comprehensive `firestore.rules` — see ADR-0013)
