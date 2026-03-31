import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/app_notification.dart';

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
  });
}
