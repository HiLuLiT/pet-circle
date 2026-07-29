import 'dart:convert';
import 'dart:developer' as developer;

/// Helpers for reading the structured fields a Cloud Function puts in an FCM
/// `data` payload.
///
/// FCM data values are always strings, so anything richer than a string has to
/// be encoded by the sender and decoded here. These live outside
/// `PushNotificationService` so they can be tested without a Firebase
/// dependency — the ID helper in particular guards a Firestore document path.

/// Upper bound on an accepted document ID, in UTF-16 code units. Firestore's
/// own limit is 1500 bytes; this is a cheap sanity bound in the same range
/// rather than an exact byte-length check.
const int _maxDocumentIdLength = 1500;

/// Validate a payload-supplied Firestore document ID.
///
/// Returns the trimmed ID, or `null` if it is absent or unusable. The value
/// arrives in a push payload and is used to build the path the client writes to
/// when marking a notification read, so it is validated before use rather than
/// trusted. Callers fall back to a locally-generated ID when this returns null.
///
/// Rejects anything Firestore itself would reject or that could redirect the
/// write: non-strings, blank values, over-long values, IDs containing `/`, the
/// reserved `.` and `..` entries, and the reserved `__*__` pattern.
String? parseNotificationId(Object? value) {
  if (value is! String) return null;
  final id = value.trim();
  if (id.isEmpty || id.length > _maxDocumentIdLength) return null;
  if (id.contains('/')) return null;
  if (id == '.' || id == '..') return null;
  if (id.startsWith('__') && id.endsWith('__')) return null;
  return id;
}

/// Decode the JSON-encoded `args` list from an FCM data payload.
///
/// The sender writes `JSON.stringify(args)` because FCM data values must be
/// strings. Returns an empty list for anything unparseable, since
/// `AppNotification.args` is non-nullable and the localizer already falls back
/// to the notification's frozen text when args are insufficient.
List<String> decodeNotificationArgs(Object? value) {
  if (value is! String || value.isEmpty) return const [];
  try {
    final decoded = json.decode(value);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
  } catch (e) {
    developer.log(
      'Failed to decode notification args: $e',
      name: 'pushPayload',
    );
  }
  return const [];
}
