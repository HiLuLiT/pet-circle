import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/reminder.dart';

import '../helpers/fake_document_snapshot.dart';

Reminder _makeReminder({
  String id = 'rem-1',
  String petId = 'pet-1',
  DateTime? date,
  String title = 'Vet visit',
  String? detail = 'Bring vaccination card',
  DateTime? createdAt,
}) {
  return Reminder(
    id: id,
    petId: petId,
    date: date ?? DateTime(2026, 4, 1),
    title: title,
    detail: detail,
    createdAt: createdAt ?? DateTime(2026, 3, 1),
  );
}

void main() {
  group('Reminder construction', () {
    test('all required fields are set correctly', () {
      final reminder = _makeReminder();

      expect(reminder.id, 'rem-1');
      expect(reminder.petId, 'pet-1');
      expect(reminder.date, DateTime(2026, 4, 1));
      expect(reminder.title, 'Vet visit');
      expect(reminder.detail, 'Bring vaccination card');
      expect(reminder.createdAt, DateTime(2026, 3, 1));
    });

    test('detail and createdAt can be null', () {
      final reminder = Reminder(
        id: 'rem-min',
        petId: 'pet-1',
        date: DateTime(2026, 1, 1),
        title: 'Grooming',
      );

      expect(reminder.detail, isNull);
      expect(reminder.createdAt, isNull);
    });
  });

  group('Reminder toFirestore', () {
    test('toFirestore includes all required fields', () {
      final reminder = _makeReminder();
      final map = reminder.toFirestore();

      expect(map['petId'], 'pet-1');
      expect(map['title'], 'Vet visit');
      expect(map['date'], isA<Timestamp>());
    });

    test('toFirestore does not include id', () {
      final reminder = _makeReminder();
      final map = reminder.toFirestore();

      expect(map.containsKey('id'), isFalse);
    });

    test('toFirestore includes detail when set and non-empty', () {
      final reminder = _makeReminder(detail: 'See Dr. Rose');
      final map = reminder.toFirestore();

      expect(map['detail'], 'See Dr. Rose');
    });

    test('toFirestore includes createdAt as Timestamp when set', () {
      final reminder = _makeReminder(createdAt: DateTime(2026, 2, 2));
      final map = reminder.toFirestore();

      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), DateTime(2026, 2, 2));
    });

    test('toFirestore omits detail when null', () {
      final reminder = Reminder(
        id: 'rem-nodet',
        petId: 'pet-1',
        date: DateTime(2026, 1, 1),
        title: 'No detail',
        detail: null,
      );
      final map = reminder.toFirestore();

      expect(map.containsKey('detail'), isFalse);
    });

    test('toFirestore omits detail when empty string', () {
      final reminder = Reminder(
        id: 'rem-empty',
        petId: 'pet-1',
        date: DateTime(2026, 1, 1),
        title: 'Empty detail',
        detail: '',
      );
      final map = reminder.toFirestore();

      expect(map.containsKey('detail'), isFalse);
    });

    test('toFirestore omits createdAt when null', () {
      final reminder = Reminder(
        id: 'rem-nocreated',
        petId: 'pet-1',
        date: DateTime(2026, 1, 1),
        title: 'No createdAt',
      );
      final map = reminder.toFirestore();

      expect(map.containsKey('createdAt'), isFalse);
    });

    test('toFirestore converts date to Timestamp', () {
      final reminder = _makeReminder();
      final map = reminder.toFirestore();

      expect((map['date'] as Timestamp).toDate(), DateTime(2026, 4, 1));
    });
  });

  group('Reminder fromFirestore', () {
    test('fromFirestore creates Reminder with all fields', () {
      final doc = FakeDocumentSnapshot('rem-1', {
        'petId': 'pet-1',
        'date': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'title': 'Vet visit',
        'detail': 'Bring vaccination card',
        'createdAt': Timestamp.fromDate(DateTime(2026, 3, 1)),
      });

      final reminder = Reminder.fromFirestore(doc);

      expect(reminder.id, 'rem-1');
      expect(reminder.petId, 'pet-1');
      expect(reminder.date, DateTime(2026, 4, 1));
      expect(reminder.title, 'Vet visit');
      expect(reminder.detail, 'Bring vaccination card');
      expect(reminder.createdAt, DateTime(2026, 3, 1));
    });

    test('fromFirestore handles missing optional fields', () {
      final doc = FakeDocumentSnapshot('rem-2', {
        'petId': 'pet-1',
        'date': Timestamp.fromDate(DateTime(2026, 5, 1)),
        'title': 'Grooming',
      });

      final reminder = Reminder.fromFirestore(doc);

      expect(reminder.id, 'rem-2');
      expect(reminder.title, 'Grooming');
      expect(reminder.detail, isNull);
      expect(reminder.createdAt, isNull);
    });

    test('fromFirestore defaults petId/title to empty string when missing', () {
      final doc = FakeDocumentSnapshot('rem-3', {
        'date': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      final reminder = Reminder.fromFirestore(doc);

      expect(reminder.petId, '');
      expect(reminder.title, '');
    });
  });

  group('Reminder round-trip', () {
    test('fromFirestore roundtrips with toFirestore (all fields)', () {
      final original = _makeReminder();
      final map = original.toFirestore();
      final doc = FakeDocumentSnapshot('rem-1', map);
      final restored = Reminder.fromFirestore(doc);

      expect(restored.id, original.id);
      expect(restored.petId, original.petId);
      expect(restored.date, original.date);
      expect(restored.title, original.title);
      expect(restored.detail, original.detail);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromFirestore roundtrips with toFirestore (minimal fields)', () {
      final original = Reminder(
        id: 'rem-min',
        petId: 'pet-2',
        date: DateTime(2026, 6, 15),
        title: 'Nail trim',
      );
      final map = original.toFirestore();
      final doc = FakeDocumentSnapshot('rem-min', map);
      final restored = Reminder.fromFirestore(doc);

      expect(restored.id, original.id);
      expect(restored.petId, original.petId);
      expect(restored.date, original.date);
      expect(restored.title, original.title);
      expect(restored.detail, isNull);
      expect(restored.createdAt, isNull);
    });
  });

  group('Reminder copyWith', () {
    test('copyWith creates a new instance', () {
      final original = _makeReminder();
      final copy = original.copyWith(title: 'Updated title');

      expect(identical(original, copy), isFalse);
      expect(copy.title, 'Updated title');
      expect(original.title, 'Vet visit');
    });

    test('copyWith preserves all fields when no args given', () {
      final original = _makeReminder();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.petId, original.petId);
      expect(copy.date, original.date);
      expect(copy.title, original.title);
      expect(copy.detail, original.detail);
      expect(copy.createdAt, original.createdAt);
    });

    test('copyWith can update each field independently', () {
      final original = _makeReminder();

      expect(original.copyWith(id: 'new-id').id, 'new-id');
      expect(original.copyWith(petId: 'pet-2').petId, 'pet-2');
      expect(
        original.copyWith(date: DateTime(2027, 1, 1)).date,
        DateTime(2027, 1, 1),
      );
      expect(original.copyWith(title: 'New title').title, 'New title');
      expect(original.copyWith(detail: 'New detail').detail, 'New detail');
      expect(
        original.copyWith(createdAt: DateTime(2027, 2, 2)).createdAt,
        DateTime(2027, 2, 2),
      );
    });

    test('clearDetail: true nulls out detail even if detail arg given', () {
      final original = _makeReminder(detail: 'Has detail');
      final cleared = original.copyWith(
        detail: 'Should be ignored',
        clearDetail: true,
      );

      expect(cleared.detail, isNull);
    });

    test('clearDetail: false (default) preserves existing detail', () {
      final original = _makeReminder(detail: 'Keep me');
      final copy = original.copyWith();

      expect(copy.detail, 'Keep me');
    });

    test('original is unchanged after copyWith', () {
      final original = _makeReminder();

      original.copyWith(title: 'Changed', clearDetail: true);

      expect(original.title, 'Vet visit');
      expect(original.detail, 'Bring vaccination card');
    });
  });
}
