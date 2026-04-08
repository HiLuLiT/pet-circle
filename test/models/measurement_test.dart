import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/measurement.dart';

import '../helpers/fake_document_snapshot.dart';

void main() {
  group('Measurement copyWith', () {
    test('copyWith creates a new instance', () {
      final original = Measurement(
        id: 'm-1',
        bpm: 22,
        recordedAt: DateTime(2025, 1, 1),
        recordedAtLabel: '1 day ago',
        recordedBy: 'Hila',
      );

      final copy = original.copyWith(bpm: 30);

      expect(identical(original, copy), isFalse);
      expect(copy.bpm, 30);
    });

    test('original is unchanged after copyWith', () {
      final original = Measurement(
        id: 'm-1',
        bpm: 22,
        recordedAt: DateTime(2025, 1, 1),
        recordedAtLabel: '1 day ago',
      );

      original.copyWith(bpm: 99, recordedAtLabel: 'new label');

      expect(original.bpm, 22);
      expect(original.recordedAtLabel, '1 day ago');
    });

    test('copyWith preserves all fields when no args given', () {
      final original = Measurement(
        id: 'm-1',
        bpm: 22,
        recordedAt: DateTime(2025, 3, 15, 10, 30),
        recordedAtLabel: 'label',
        recordedBy: 'user-1',
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.bpm, original.bpm);
      expect(copy.recordedAt, original.recordedAt);
      expect(copy.recordedAtLabel, original.recordedAtLabel);
      expect(copy.recordedBy, original.recordedBy);
    });

    test('copyWith can update each field independently', () {
      final original = Measurement(
        bpm: 22,
        recordedAt: DateTime(2025, 1, 1),
      );

      expect(original.copyWith(id: 'new-id').id, 'new-id');
      expect(original.copyWith(bpm: 50).bpm, 50);
      expect(
        original.copyWith(recordedAt: DateTime(2026, 1, 1)).recordedAt,
        DateTime(2026, 1, 1),
      );
      expect(
        original.copyWith(recordedAtLabel: 'now').recordedAtLabel,
        'now',
      );
      expect(original.copyWith(recordedBy: 'doc').recordedBy, 'doc');
    });
  });

  group('Measurement timeAgo', () {
    test('timeAgo returns recordedAtLabel when present', () {
      final m = Measurement(
        bpm: 22,
        recordedAt: DateTime(2020, 1, 1),
        recordedAtLabel: 'custom label',
      );

      expect(m.timeAgo, 'custom label');
    });

    test('timeAgo computes relative time when no label', () {
      final recent = Measurement(
        bpm: 22,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(recent.timeAgo, contains('min ago'));
    });

    test('timeAgo returns Just now for very recent', () {
      final justNow = Measurement(
        bpm: 22,
        recordedAt: DateTime.now(),
      );

      expect(justNow.timeAgo, 'Just now');
    });

    test('timeAgo returns hours for recordings hours ago', () {
      final hoursAgo = Measurement(
        bpm: 22,
        recordedAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

      expect(hoursAgo.timeAgo, '3 hours ago');
    });

    test('timeAgo returns singular hour', () {
      final oneHour = Measurement(
        bpm: 22,
        recordedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(oneHour.timeAgo, '1 hour ago');
    });

    test('timeAgo returns days for recordings days ago', () {
      final daysAgo = Measurement(
        bpm: 22,
        recordedAt: DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(daysAgo.timeAgo, '5 days ago');
    });

    test('timeAgo returns singular day', () {
      final oneDay = Measurement(
        bpm: 22,
        recordedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(oneDay.timeAgo, '1 day ago');
    });
  });

  group('Measurement construction', () {
    test('id defaults to null', () {
      final m = Measurement(bpm: 22, recordedAt: DateTime(2025, 1, 1));
      expect(m.id, isNull);
    });

    test('recordedAtLabel defaults to null', () {
      final m = Measurement(bpm: 22, recordedAt: DateTime(2025, 1, 1));
      expect(m.recordedAtLabel, isNull);
    });

    test('recordedBy defaults to null', () {
      final m = Measurement(bpm: 22, recordedAt: DateTime(2025, 1, 1));
      expect(m.recordedBy, isNull);
    });
  });

  group('Measurement toFirestore', () {
    test('toFirestore includes bpm and recordedAt', () {
      final m = Measurement(
        bpm: 22,
        recordedAt: DateTime(2025, 3, 15),
        recordedBy: 'user-1',
      );
      final map = m.toFirestore();

      expect(map['bpm'], 22);
      expect(map['recordedAt'], isA<Timestamp>());
      expect(map['recordedBy'], 'user-1');
    });

    test('toFirestore does not include id or recordedAtLabel', () {
      final m = Measurement(
        id: 'm-1',
        bpm: 22,
        recordedAt: DateTime(2025, 1, 1),
        recordedAtLabel: 'label',
      );
      final map = m.toFirestore();

      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('recordedAtLabel'), isFalse);
    });

    test('toFirestore includes null recordedBy when not set', () {
      final m = Measurement(bpm: 22, recordedAt: DateTime(2025, 1, 1));
      final map = m.toFirestore();

      expect(map['recordedBy'], isNull);
    });
  });

  group('Measurement fromFirestore', () {
    test('fromFirestore creates Measurement with Timestamp', () {
      final doc = FakeDocumentSnapshot('m-1', {
        'bpm': 22,
        'recordedAt': Timestamp.fromDate(DateTime(2025, 3, 15)),
        'recordedBy': 'user-1',
      });

      final m = Measurement.fromFirestore(doc);

      expect(m.id, 'm-1');
      expect(m.bpm, 22);
      expect(m.recordedAt, DateTime(2025, 3, 15));
      expect(m.recordedBy, 'user-1');
    });

    test('fromFirestore handles missing bpm with default 0', () {
      final doc = FakeDocumentSnapshot('m-2', {
        'recordedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final m = Measurement.fromFirestore(doc);

      expect(m.bpm, 0);
    });

    test('fromFirestore handles missing recordedBy as null', () {
      final doc = FakeDocumentSnapshot('m-3', {
        'bpm': 18,
        'recordedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final m = Measurement.fromFirestore(doc);

      expect(m.recordedBy, isNull);
    });

    test('fromFirestore handles int recordedAt (millisecondsSinceEpoch)', () {
      final epoch = DateTime(2025, 6, 1).millisecondsSinceEpoch;
      final doc = FakeDocumentSnapshot('m-4', {
        'bpm': 20,
        'recordedAt': epoch,
      });

      final m = Measurement.fromFirestore(doc);

      expect(m.recordedAt, DateTime(2025, 6, 1));
    });

    test('fromFirestore handles String recordedAt (ISO 8601)', () {
      final doc = FakeDocumentSnapshot('m-5', {
        'bpm': 20,
        'recordedAt': '2025-06-01T00:00:00.000',
      });

      final m = Measurement.fromFirestore(doc);

      expect(m.recordedAt, DateTime(2025, 6, 1));
    });

    test('fromFirestore roundtrips with toFirestore', () {
      final original = Measurement(
        bpm: 25,
        recordedAt: DateTime(2025, 3, 15, 10, 30),
        recordedBy: 'user-1',
      );
      final map = original.toFirestore();
      final doc = FakeDocumentSnapshot('m-rt', map);
      final restored = Measurement.fromFirestore(doc);

      expect(restored.id, 'm-rt');
      expect(restored.bpm, original.bpm);
      expect(restored.recordedAt, original.recordedAt);
      expect(restored.recordedBy, original.recordedBy);
    });
  });
}
