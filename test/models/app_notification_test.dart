import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/app_notification.dart';

import '../helpers/fake_document_snapshot.dart';

AppNotification _makeNotification({
  bool isRead = false,
  String? petName = 'Princess',
}) {
  return AppNotification(
    id: 'n-1',
    title: 'New Measurement',
    body: 'Princess has a new SRR reading of 22 bpm',
    type: NotificationType.measurement,
    createdAt: DateTime(2025, 3, 15, 10, 30),
    isRead: isRead,
    petName: petName,
  );
}

void main() {
  group('AppNotification construction', () {
    test('creates with all required fields', () {
      final notification = _makeNotification();

      expect(notification.id, 'n-1');
      expect(notification.title, 'New Measurement');
      expect(notification.body, contains('Princess'));
      expect(notification.type, NotificationType.measurement);
      expect(notification.createdAt, DateTime(2025, 3, 15, 10, 30));
    });

    test('isRead defaults to false', () {
      final notification = AppNotification(
        id: 'n-2',
        title: 'Alert',
        body: 'Body text',
        type: NotificationType.medication,
        createdAt: DateTime(2025, 1, 1),
      );

      expect(notification.isRead, isFalse);
    });

    test('petName defaults to null', () {
      final notification = AppNotification(
        id: 'n-3',
        title: 'Alert',
        body: 'Body text',
        type: NotificationType.careCircle,
        createdAt: DateTime(2025, 1, 1),
      );

      expect(notification.petName, isNull);
    });

    test('all NotificationType values are distinct', () {
      final types = NotificationType.values;
      expect(types.length, 4);
      expect(types.toSet().length, 4);
    });
  });

  group('AppNotification copyWith', () {
    test('copyWith creates a new instance', () {
      final original = _makeNotification();
      final copy = original.copyWith(title: 'Updated');

      expect(identical(original, copy), isFalse);
      expect(copy.title, 'Updated');
      expect(original.title, 'New Measurement');
    });

    test('copyWith preserves all fields when no args given', () {
      final original = _makeNotification();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.body, original.body);
      expect(copy.type, original.type);
      expect(copy.createdAt, original.createdAt);
      expect(copy.isRead, original.isRead);
      expect(copy.petName, original.petName);
    });

    test('original is unchanged after copyWith', () {
      final original = _makeNotification();

      original.copyWith(
        title: 'Changed',
        isRead: true,
        petName: 'Buddy',
      );

      expect(original.title, 'New Measurement');
      expect(original.isRead, isFalse);
      expect(original.petName, 'Princess');
    });

    test('copyWith can update each field independently', () {
      final original = _makeNotification();

      expect(original.copyWith(id: 'new-id').id, 'new-id');
      expect(original.copyWith(title: 'New Title').title, 'New Title');
      expect(original.copyWith(body: 'New body').body, 'New body');
      expect(
        original.copyWith(type: NotificationType.report).type,
        NotificationType.report,
      );
      expect(
        original.copyWith(createdAt: DateTime(2026, 1, 1)).createdAt,
        DateTime(2026, 1, 1),
      );
      expect(original.copyWith(isRead: true).isRead, isTrue);
      expect(original.copyWith(petName: 'Rex').petName, 'Rex');
    });
  });

  group('AppNotification timeAgo', () {
    test('timeAgo returns Just now for very recent', () {
      final notification = AppNotification(
        id: 'n-now',
        title: 'Test',
        body: 'Body',
        type: NotificationType.measurement,
        createdAt: DateTime.now(),
      );

      expect(notification.timeAgo, 'Just now');
    });

    test('timeAgo returns minutes for recent notification', () {
      final notification = AppNotification(
        id: 'n-min',
        title: 'Test',
        body: 'Body',
        type: NotificationType.measurement,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );

      expect(notification.timeAgo, '15m ago');
    });

    test('timeAgo returns hours for older notification', () {
      final notification = AppNotification(
        id: 'n-hr',
        title: 'Test',
        body: 'Body',
        type: NotificationType.measurement,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

      expect(notification.timeAgo, '3h ago');
    });

    test('timeAgo returns days for old notification', () {
      final notification = AppNotification(
        id: 'n-day',
        title: 'Test',
        body: 'Body',
        type: NotificationType.measurement,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(notification.timeAgo, '5d ago');
    });
  });

  group('AppNotification toFirestore', () {
    test('toFirestore includes all fields', () {
      final notification = _makeNotification();
      final map = notification.toFirestore();

      expect(map['title'], 'New Measurement');
      expect(map['body'], contains('Princess'));
      expect(map['type'], 'measurement');
      expect(map['isRead'], isFalse);
      expect(map['petName'], 'Princess');
      expect(map.containsKey('createdAt'), isTrue);
    });

    test('toFirestore serializes type name correctly', () {
      final types = {
        NotificationType.measurement: 'measurement',
        NotificationType.medication: 'medication',
        NotificationType.careCircle: 'careCircle',
        NotificationType.report: 'report',
      };

      for (final entry in types.entries) {
        final notification = AppNotification(
          id: 'n-test',
          title: 'Test',
          body: 'Body',
          type: entry.key,
          createdAt: DateTime(2025, 1, 1),
        );

        expect(notification.toFirestore()['type'], entry.value);
      }
    });

    test('toFirestore does not include id', () {
      final notification = _makeNotification();
      final map = notification.toFirestore();

      expect(map.containsKey('id'), isFalse);
    });

    test('toFirestore converts createdAt to Timestamp', () {
      final notification = _makeNotification();
      final map = notification.toFirestore();

      expect(map['createdAt'], isA<Timestamp>());
    });

    test('toFirestore includes null petName when not set', () {
      final notification = AppNotification(
        id: 'n-no-pet',
        title: 'Test',
        body: 'Body',
        type: NotificationType.careCircle,
        createdAt: DateTime(2025, 1, 1),
      );
      final map = notification.toFirestore();

      expect(map['petName'], isNull);
    });
  });

  group('AppNotification fromFirestore', () {
    test('fromFirestore creates notification with all fields', () {
      final doc = FakeDocumentSnapshot('n-1', {
        'title': 'New Measurement',
        'body': 'Princess has a new SRR reading',
        'type': 'measurement',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 15, 10, 30)),
        'isRead': false,
        'petName': 'Princess',
      });

      final n = AppNotification.fromFirestore(doc);

      expect(n.id, 'n-1');
      expect(n.title, 'New Measurement');
      expect(n.body, contains('Princess'));
      expect(n.type, NotificationType.measurement);
      expect(n.createdAt, DateTime(2025, 3, 15, 10, 30));
      expect(n.isRead, isFalse);
      expect(n.petName, 'Princess');
    });

    test('fromFirestore deserializes all type values', () {
      final typeMap = {
        'measurement': NotificationType.measurement,
        'medication': NotificationType.medication,
        'careCircle': NotificationType.careCircle,
        'report': NotificationType.report,
      };

      for (final entry in typeMap.entries) {
        final doc = FakeDocumentSnapshot('n-type', {
          'title': 'T',
          'body': 'B',
          'type': entry.key,
          'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        });

        final n = AppNotification.fromFirestore(doc);
        expect(n.type, entry.value);
      }
    });

    test('fromFirestore defaults unknown type to measurement', () {
      final doc = FakeDocumentSnapshot('n-unk', {
        'title': 'T',
        'body': 'B',
        'type': 'unknownType',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final n = AppNotification.fromFirestore(doc);
      expect(n.type, NotificationType.measurement);
    });

    test('fromFirestore defaults null type to measurement', () {
      final doc = FakeDocumentSnapshot('n-null-type', {
        'title': 'T',
        'body': 'B',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final n = AppNotification.fromFirestore(doc);
      expect(n.type, NotificationType.measurement);
    });

    test('fromFirestore handles missing optional fields', () {
      final doc = FakeDocumentSnapshot('n-min', {
        'title': 'Alert',
        'body': 'Body text',
        'type': 'medication',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final n = AppNotification.fromFirestore(doc);

      expect(n.isRead, isFalse);
      expect(n.petName, isNull);
    });

    test('fromFirestore defaults missing title/body to empty string', () {
      final doc = FakeDocumentSnapshot('n-empty', {
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final n = AppNotification.fromFirestore(doc);

      expect(n.title, '');
      expect(n.body, '');
    });

    test('fromFirestore handles null createdAt gracefully', () {
      final doc = FakeDocumentSnapshot('n-no-date', {
        'title': 'Test',
        'body': 'Body',
        'type': 'measurement',
      });

      final n = AppNotification.fromFirestore(doc);

      // When createdAt is null, it falls back to DateTime.now()
      expect(n.createdAt, isNotNull);
    });

    test('fromFirestore roundtrips with toFirestore', () {
      final original = _makeNotification();
      final map = original.toFirestore();
      final doc = FakeDocumentSnapshot('n-1', map);
      final restored = AppNotification.fromFirestore(doc);

      expect(restored.id, 'n-1');
      expect(restored.title, original.title);
      expect(restored.body, original.body);
      expect(restored.type, original.type);
      expect(restored.createdAt, original.createdAt);
      expect(restored.isRead, original.isRead);
      expect(restored.petName, original.petName);
    });
  });

  group('AppNotification localization keys', () {
    AppNotification keyed() => AppNotification(
          id: 'n-key',
          title: 'Measurement Complete',
          body: 'Measurement saved: 12 BPM',
          titleKey: 'measurementComplete',
          bodyKey: 'measurementSavedBpm',
          args: const ['12'],
          type: NotificationType.measurement,
          createdAt: DateTime(2025, 1, 1),
        );

    test('args default to empty list and keys to null', () {
      final n = _makeNotification();
      expect(n.titleKey, isNull);
      expect(n.bodyKey, isNull);
      expect(n.args, isEmpty);
    });

    test('stores titleKey, bodyKey and args', () {
      final n = keyed();
      expect(n.titleKey, 'measurementComplete');
      expect(n.bodyKey, 'measurementSavedBpm');
      expect(n.args, ['12']);
    });

    test('toFirestore includes keys and args when present', () {
      final map = keyed().toFirestore();
      expect(map['titleKey'], 'measurementComplete');
      expect(map['bodyKey'], 'measurementSavedBpm');
      expect(map['args'], ['12']);
    });

    test('toFirestore omits keys and args when absent', () {
      final map = _makeNotification().toFirestore();
      expect(map.containsKey('titleKey'), isFalse);
      expect(map.containsKey('bodyKey'), isFalse);
      expect(map.containsKey('args'), isFalse);
    });

    test('fromFirestore restores keys and args', () {
      final doc = FakeDocumentSnapshot('n-key', {
        'title': 'Measurement Complete',
        'body': 'Measurement saved: 12 BPM',
        'titleKey': 'measurementComplete',
        'bodyKey': 'measurementSavedBpm',
        'args': ['12'],
        'type': 'measurement',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final n = AppNotification.fromFirestore(doc);
      expect(n.titleKey, 'measurementComplete');
      expect(n.bodyKey, 'measurementSavedBpm');
      expect(n.args, ['12']);
    });

    test('fromFirestore defaults missing keys to null and args to empty', () {
      final doc = FakeDocumentSnapshot('n-legacy', {
        'title': 'Legacy',
        'body': 'No keys here',
        'type': 'medication',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final n = AppNotification.fromFirestore(doc);
      expect(n.titleKey, isNull);
      expect(n.bodyKey, isNull);
      expect(n.args, isEmpty);
    });

    test('keyed notification roundtrips through Firestore', () {
      final original = keyed();
      final doc = FakeDocumentSnapshot('n-key', original.toFirestore());
      final restored = AppNotification.fromFirestore(doc);

      expect(restored.titleKey, original.titleKey);
      expect(restored.bodyKey, original.bodyKey);
      expect(restored.args, original.args);
    });

    test('copyWith updates keys and args independently', () {
      final original = _makeNotification();
      expect(original.copyWith(titleKey: 'medicationAdded').titleKey,
          'medicationAdded');
      expect(original.copyWith(bodyKey: 'vetInviteSent').bodyKey,
          'vetInviteSent');
      expect(original.copyWith(args: const ['a', 'b']).args, ['a', 'b']);
    });

    test('copyWith preserves keys and args when not given', () {
      final copy = keyed().copyWith(isRead: true);
      expect(copy.titleKey, 'measurementComplete');
      expect(copy.bodyKey, 'measurementSavedBpm');
      expect(copy.args, ['12']);
    });
  });
}
