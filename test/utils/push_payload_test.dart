import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations_en.dart';
import 'package:pet_circle/l10n/app_localizations_he.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/utils/notification_localizer.dart';
import 'package:pet_circle/utils/push_payload.dart';

/// Builds an [AppNotification] the way `PushNotificationService`
/// `_handleForegroundMessage` does, from an FCM `data` map.
AppNotification _fromPayload(Map<String, dynamic> data) {
  return AppNotification(
    id: parseNotificationId(data['notificationId']) ?? 'fallback-id',
    // The frozen English strings the server sends for the OS banner.
    title: 'a@b.com joined Rex\'s care circle',
    body: 'Your invitation was accepted',
    type: NotificationType.careCircle,
    createdAt: DateTime(2026, 1, 1),
    petName: data['petName'],
    route: data['route'],
    petId: data['petId'],
    titleKey: data['titleKey'] as String?,
    bodyKey: data['bodyKey'] as String?,
    args: decodeNotificationArgs(data['args']),
  );
}

void main() {
  group('parseNotificationId', () {
    test('accepts a normal Firestore auto-ID', () {
      expect(parseNotificationId('AbC123xYz456'), 'AbC123xYz456');
    });

    test('trims surrounding whitespace', () {
      expect(parseNotificationId('  abc123  '), 'abc123');
    });

    test('returns null for a non-string', () {
      expect(parseNotificationId(null), isNull);
      expect(parseNotificationId(42), isNull);
      expect(parseNotificationId(const ['abc']), isNull);
    });

    test('returns null for empty or whitespace-only input', () {
      expect(parseNotificationId(''), isNull);
      expect(parseNotificationId('   '), isNull);
    });

    test('rejects an ID containing a path separator', () {
      expect(parseNotificationId('abc/def'), isNull);
      expect(parseNotificationId('../../users/victim'), isNull);
      expect(parseNotificationId('/abc'), isNull);
    });

    test('rejects the reserved . and .. entries', () {
      expect(parseNotificationId('.'), isNull);
      expect(parseNotificationId('..'), isNull);
    });

    test('rejects the reserved __*__ pattern', () {
      expect(parseNotificationId('__name__'), isNull);
      expect(parseNotificationId('__id__'), isNull);
    });

    test('allows a leading underscore that is not the reserved pattern', () {
      expect(parseNotificationId('__notReserved'), '__notReserved');
      expect(parseNotificationId('_abc'), '_abc');
    });

    test('rejects an over-long ID', () {
      expect(parseNotificationId('x' * 1501), isNull);
    });

    test('accepts an ID at the length limit', () {
      final id = 'x' * 1500;
      expect(parseNotificationId(id), id);
    });
  });

  group('decodeNotificationArgs', () {
    test('decodes a JSON string array', () {
      expect(decodeNotificationArgs('["a@b.com","Rex"]'), ['a@b.com', 'Rex']);
    });

    test('returns an empty list for a non-string', () {
      expect(decodeNotificationArgs(null), isEmpty);
      expect(decodeNotificationArgs(42), isEmpty);
    });

    test('returns an empty list for an empty string', () {
      expect(decodeNotificationArgs(''), isEmpty);
    });

    test('returns an empty list for malformed JSON', () {
      expect(decodeNotificationArgs('not json'), isEmpty);
      expect(decodeNotificationArgs('["unterminated'), isEmpty);
    });

    test('returns an empty list when the JSON is not a list', () {
      expect(decodeNotificationArgs('{"a":1}'), isEmpty);
      expect(decodeNotificationArgs('"a string"'), isEmpty);
      expect(decodeNotificationArgs('12'), isEmpty);
    });

    test('decodes an empty JSON array', () {
      expect(decodeNotificationArgs('[]'), isEmpty);
    });

    test('stringifies non-string list members', () {
      expect(decodeNotificationArgs('[1,2.5,true,null]'), [
        '1',
        '2.5',
        'true',
        'null',
      ]);
    });

    test('preserves order, matching the localizer positional args', () {
      // notification_localizer reads args[0] as email and args[1] as petName
      // for inviteAcceptedTitle, so ordering is load-bearing.
      final args = decodeNotificationArgs('["first","second","third"]');
      expect(args[0], 'first');
      expect(args[1], 'second');
      expect(args[2], 'third');
    });

    test('handles unicode payloads', () {
      // Escapes on both sides rather than literal Hebrew, so the assertion
      // cannot be misread when the file is rendered with bidi reordering.
      expect(decodeNotificationArgs('["\\u05e8\\u05e7\\u05e1"]'), [
        '\u05e8\u05e7\u05e1',
      ]);
    });
  });

  group('server push payload end-to-end (BUG-038 / BUG-039)', () {
    final en = AppLocalizationsEn();
    final he = AppLocalizationsHe();

    // The exact data map `onInvitationStatusChanged` sends.
    Map<String, dynamic> payload() => {
      'type': 'careCircle',
      'route': '/shell',
      'petId': 'pet-1',
      'petName': 'Rex',
      'invitedEmail': 'a@b.com',
      'titleKey': 'inviteAcceptedTitle',
      'bodyKey': 'inviteAcceptedBody',
      'args': '["a@b.com","Rex"]',
      'notificationId': 'srv-doc-123',
    };

    test('keeps the server document ID so markRead can find the doc', () {
      expect(_fromPayload(payload()).id, 'srv-doc-123');
    });

    test('falls back when the server sends no notificationId', () {
      final data = payload()..remove('notificationId');
      expect(_fromPayload(data).id, 'fallback-id');
    });

    test('localizes title and body in English', () {
      final n = _fromPayload(payload());
      final out = localizeNotification(n, en);

      expect(out.title, en.inviteAcceptedTitle('a@b.com', 'Rex'));
      expect(out.body, en.inviteAcceptedBody);
    });

    test('localizes title and body in Hebrew', () {
      final n = _fromPayload(payload());
      final out = localizeNotification(n, he);

      expect(out.title, he.inviteAcceptedTitle('a@b.com', 'Rex'));
      expect(out.body, he.inviteAcceptedBody);
      // The whole point of BUG-039: the Hebrew reader must not see the frozen
      // English text the server sent for the OS banner.
      expect(out.title, isNot(n.title));
      expect(out.body, isNot(n.body));
    });

    test('falls back to the frozen server text when args are malformed', () {
      final data = payload()..['args'] = 'not json';
      final n = _fromPayload(data);
      final out = localizeNotification(n, he);

      // titleKey needs two args; with none it degrades to the frozen title
      // rather than throwing. bodyKey is static, so it still localizes.
      expect(out.title, n.title);
      expect(out.body, he.inviteAcceptedBody);
    });

    test('carries route and petId through for tap routing', () {
      final n = _fromPayload(payload());
      expect(n.route, '/shell');
      expect(n.petId, 'pet-1');
      expect(n.petName, 'Rex');
      expect(n.type, NotificationType.careCircle);
    });
  });
}
