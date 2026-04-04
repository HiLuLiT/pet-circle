# ADR-0014: Token-Based Deep Link Invitation System

**Date**: 2026-03-15
**Status**: accepted
**Deciders**: Project team

## Context

Pet owners need to invite veterinarians and other caregivers to their pet's care circle. The invitation must work across platforms (native deep link + web URL) and be secure against replay attacks. Firebase Dynamic Links has been deprecated by Google.

## Decision

Use 32-character random tokens stored in `/invitations/{token}` with a shadow `pendingInvites.{token}` entry on the pet document. Tokens are shared via deep link (`/invite?token=XYZ`). Expiry: 7 days. Rate limit: 5 invites/user/day. Max 2 vets per pet.

## Alternatives Considered

### Alternative 1: Firebase Dynamic Links
- **Pros**: Built-in deferred deep linking, analytics
- **Cons**: Deprecated by Google, sunset date announced
- **Why not**: Building on a deprecated service would require migration later

### Alternative 2: Email-only invitation
- **Pros**: Simple, no deep link infrastructure needed
- **Cons**: No in-app flow, requires email integration, poor mobile UX
- **Why not**: Deep links provide a seamless in-app acceptance experience

### Alternative 3: Share code (short code)
- **Pros**: Easy to communicate verbally
- **Cons**: Short codes are guessable, less secure than 32-char tokens
- **Why not**: Security requirement — tokens must not be brute-forceable

## Consequences

### Positive
- Deep links work cross-platform (web URL bar + native `app_links`)
- Dual-store pattern allows Firestore rules to validate acceptance atomically
- `InvitationService.acceptInvitation` uses a Firestore transaction for atomicity
- Rate limits and vet caps prevent abuse

### Negative
- Dual storage (invitation doc + pet pendingInvites) adds sync complexity
- Tokens must be communicated out-of-band (copy link, share)
- Expired tokens require cleanup

### Risks
- Token leakage (mitigated by 7-day expiry and one-time use)
- Race conditions in acceptance (mitigated by Firestore transactions)
