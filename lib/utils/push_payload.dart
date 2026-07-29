import 'dart:convert';
import 'dart:developer' as developer;

import 'package:pet_circle/models/app_notification.dart';

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

/// Build an [AppNotification] from an FCM `data` payload.
///
/// This is the whole client half of the push contract with the Cloud Functions
/// triggers in `functions/src/`, kept here rather than inline in
/// `PushNotificationService` so it can be tested directly — the service itself
/// needs a live Firebase binding.
///
/// [title] and [body] are the frozen strings the server sends for the OS
/// banner; they act as the fallback whenever `titleKey`/`bodyKey` are absent or
/// unresolvable. [fallbackId] is used when the payload carries no usable
/// `notificationId` (e.g. sent by an older function version).
AppNotification appNotificationFromPushData(
  Map<String, dynamic> data, {
  required String title,
  required String body,
  required String fallbackId,
  required DateTime createdAt,
}) {
  return AppNotification(
    id: parseNotificationId(data['notificationId']) ?? fallbackId,
    title: title,
    body: body,
    type: notificationTypeFromPushData(data),
    createdAt: createdAt,
    petName: data['petName'] as String?,
    route: data['route'] as String?,
    petId: data['petId'] as String?,
    titleKey: data['titleKey'] as String?,
    bodyKey: data['bodyKey'] as String?,
    args: decodeNotificationArgs(data['args']),
  );
}

/// Map the payload's `type` field onto [NotificationType], defaulting to
/// [NotificationType.measurement] for unknown or missing values.
NotificationType notificationTypeFromPushData(Map<String, dynamic> data) {
  switch (data['type'] as String?) {
    case 'medication':
      return NotificationType.medication;
    case 'careCircle':
      return NotificationType.careCircle;
    case 'report':
      return NotificationType.report;
    case 'measurement':
    default:
      return NotificationType.measurement;
  }
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
