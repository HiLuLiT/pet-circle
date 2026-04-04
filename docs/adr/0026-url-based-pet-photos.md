# ADR-0026: URL-Based Pet Photos (Firebase Storage Deferred)

**Date**: 2026-01-20
**Status**: accepted
**Deciders**: Project team

## Context

Pets need profile photos. The full solution would be camera/gallery upload to Firebase Storage, but Storage integration was deferred to keep the MVP scope small.

## Decision

Store pet photos as URL strings (`imageUrl` field on the `Pet` model). Users enter a URL manually during onboarding. `DogPhoto` widget loads from URL with placeholder fallback.

## Alternatives Considered

### Alternative 1: image_picker + Firebase Storage upload
- **Pros**: Native camera/gallery picker, proper file storage
- **Cons**: Requires Firebase Storage setup, upload UI, error handling
- **Why not**: Deferred per `firebase-status.md`: "firebase_storage for pet photo upload when image management becomes a product requirement." Note: `image_picker` is already in pubspec.yaml for future use.

### Alternative 2: Base64 encoding in Firestore
- **Pros**: No separate storage service
- **Cons**: Firestore document size limits (1MB), slow reads, no CDN
- **Why not**: Terrible for performance and scalability

## Consequences

### Positive
- Zero backend storage infrastructure needed
- Simple implementation
- `DogPhoto` widget gracefully handles missing/broken URLs

### Negative
- Poor UX — users must find and paste a URL
- No image cropping, resizing, or optimization
- External URLs may break (404, CORS issues)

### Risks
- Broken image URLs over time (mitigated by placeholder fallback)
