# ADR-0013: Security Rules-Enforced Access Control (Not Cloud Functions)

**Date**: 2026-03-10
**Status**: accepted
**Deciders**: Project team

## Context

The app needs role-based access control: pet Admin/Member/Viewer roles with different read/write permissions. The choice is between enforcing authorization in Firestore security rules (client-side writes validated by rules) or in Cloud Functions (server-side writes).

## Decision

All authorization logic lives in `firestore.rules`. No Cloud Functions for access control. Rules implement full RBAC with invitation replay attack prevention via `lastAcceptedInvitationToken` + `pendingInvites` map.

## Alternatives Considered

### Alternative 1: Cloud Functions as security layer
- **Pros**: Full server-side logic, can do complex validation, no client trust
- **Cons**: Adds latency (cold starts), costs money per invocation, requires server maintenance
- **Why not**: Security rules execute at the database layer with zero latency; Cloud Functions are deferred to future phases

### Alternative 2: Trust the client (minimal rules)
- **Pros**: Simplest implementation, no rules to maintain
- **Cons**: Any authenticated user could modify any data
- **Why not**: Completely insecure for a multi-user health data app

### Alternative 3: Simple allow-own-data rules
- **Pros**: Easy to write and maintain
- **Cons**: Can't express care circle permissions (user A reading user B's pet data)
- **Why not**: The care circle model requires cross-user data access with role-based granularity

## Consequences

### Positive
- Zero latency — rules execute at the database layer
- No Cloud Functions cost or cold start delays
- `diff().affectedKeys().hasOnly([...])` constrains exactly which fields can change per operation
- Invitation hardening prevents privilege escalation without valid pending invite

### Negative
- Security rules language is limited (no loops, limited functions)
- Complex rules are hard to read and test
- No server-side business logic (all validation must be expressible in rules)
- Rules must be deployed separately (`firebase deploy --only firestore:rules`)

### Risks
- Rules complexity grows with features (mitigated by thorough testing and documentation)
- A rules bug could expose user data (mitigated by principle of least privilege — deny by default)
