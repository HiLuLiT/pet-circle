# ADR-0035: Two-Tier Role System (App-Level + Per-Pet)

**Date**: 2026-03-10
**Status**: accepted
**Deciders**: Project team

## Context

The app has two types of users (pet owners and veterinarians) who interact with pet data differently. Within a pet's care circle, multiple users need different permission levels. A single flat role system cannot express "vet who is a viewer on pet A but an admin on pet B."

## Decision

Two orthogonal role dimensions:
1. **App-level role** (`AppUserRole.owner` / `AppUserRole.vet`) — selected at sign-up, determines dashboard layout and available features
2. **Per-pet care circle role** (`CareCircleRole.admin` / `member` / `viewer`) — determined by invitation, controls data permissions per pet

## Alternatives Considered

### Alternative 1: Single flat role system
- **Pros**: Simple, one role per user
- **Cons**: Cannot express "vet who is a viewer on one pet and admin on another"
- **Why not**: The care circle model inherently requires per-pet permissions

### Alternative 2: Separate vet and owner apps
- **Pros**: Clean separation, tailored UX per role
- **Cons**: Double the development, vets who own pets need two apps
- **Why not**: A single app with role-based routing is more practical

### Alternative 3: Role assigned by admin only (no self-selection)
- **Pros**: Prevents incorrect role selection
- **Cons**: Requires admin infrastructure, blocks onboarding
- **Why not**: Self-selection at sign-up with Firestore rules enforcement is sufficient

## Consequences

### Positive
- Fine-grained permissions: admin-only edit buttons, member can measure, viewer can only read
- `PetAccess` model encapsulates resolved role with `PetAccessSource` for migration
- Firestore security rules enforce both tiers (`careCircle[uid].role` for per-pet, user doc for app-level)
- Dashboard adapts to app-level role (owner sees pet care, vet sees patient list)

### Negative
- Two role concepts to explain to users
- Permission resolution logic in both rules and UI code
- Role changes require updating both tiers if applicable

### Risks
- Permission escalation (mitigated by Firestore rules that validate role transitions)
