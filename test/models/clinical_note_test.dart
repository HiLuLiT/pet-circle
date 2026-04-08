import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/clinical_note.dart';

import '../helpers/fake_document_snapshot.dart';

ClinicalNote _makeNote() {
  return ClinicalNote(
    id: 'note-1',
    authorUid: 'u-1',
    authorName: 'Dr. Smith',
    authorAvatarUrl: 'https://example.com/smith.png',
    content: 'Heart murmur grade 3/6, recommend echocardiogram.',
    createdAt: DateTime(2025, 3, 15, 14, 30),
  );
}

void main() {
  group('ClinicalNote construction', () {
    test('creates with all required fields', () {
      final note = _makeNote();

      expect(note.id, 'note-1');
      expect(note.authorUid, 'u-1');
      expect(note.authorName, 'Dr. Smith');
      expect(note.authorAvatarUrl, 'https://example.com/smith.png');
      expect(note.content, contains('Heart murmur'));
      expect(note.createdAt, DateTime(2025, 3, 15, 14, 30));
    });

    test('authorUid can be null', () {
      final note = ClinicalNote(
        id: 'note-2',
        authorName: 'Anonymous',
        authorAvatarUrl: '',
        content: 'Some note',
        createdAt: DateTime(2025, 1, 1),
      );

      expect(note.authorUid, isNull);
    });

    test('can create with empty strings', () {
      final note = ClinicalNote(
        id: '',
        authorName: '',
        authorAvatarUrl: '',
        content: '',
        createdAt: DateTime(2025, 1, 1),
      );

      expect(note.id, '');
      expect(note.authorName, '');
      expect(note.content, '');
    });
  });

  group('ClinicalNote timeAgo', () {
    test('returns Just now for very recent notes', () {
      final note = ClinicalNote(
        id: 'note-now',
        authorName: 'Dr. Test',
        authorAvatarUrl: '',
        content: 'Recent note',
        createdAt: DateTime.now(),
      );

      expect(note.timeAgo, 'Just now');
    });

    test('returns minutes with min ago suffix', () {
      final note = ClinicalNote(
        id: 'note-min',
        authorName: 'Dr. Test',
        authorAvatarUrl: '',
        content: 'Test',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      expect(note.timeAgo, '10 min ago');
    });

    test('returns singular hour', () {
      final note = ClinicalNote(
        id: 'note-1h',
        authorName: 'Dr. Test',
        authorAvatarUrl: '',
        content: 'Test',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(note.timeAgo, '1 hour ago');
    });

    test('returns plural hours', () {
      final note = ClinicalNote(
        id: 'note-hrs',
        authorName: 'Dr. Test',
        authorAvatarUrl: '',
        content: 'Test',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      );

      expect(note.timeAgo, '5 hours ago');
    });

    test('returns singular day', () {
      final note = ClinicalNote(
        id: 'note-1d',
        authorName: 'Dr. Test',
        authorAvatarUrl: '',
        content: 'Test',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(note.timeAgo, '1 day ago');
    });

    test('returns plural days', () {
      final note = ClinicalNote(
        id: 'note-days',
        authorName: 'Dr. Test',
        authorAvatarUrl: '',
        content: 'Test',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      );

      expect(note.timeAgo, '7 days ago');
    });
  });

  group('ClinicalNote toFirestore', () {
    test('toFirestore includes all fields', () {
      final note = _makeNote();
      final map = note.toFirestore();

      expect(map['authorUid'], 'u-1');
      expect(map['authorName'], 'Dr. Smith');
      expect(map['authorAvatarUrl'], 'https://example.com/smith.png');
      expect(map['content'], contains('Heart murmur'));
      expect(map.containsKey('createdAt'), isTrue);
    });

    test('toFirestore does not include id', () {
      final note = _makeNote();
      final map = note.toFirestore();

      expect(map.containsKey('id'), isFalse);
    });

    test('toFirestore includes null authorUid when not set', () {
      final note = ClinicalNote(
        id: 'note-no-uid',
        authorName: 'Guest',
        authorAvatarUrl: '',
        content: 'Note',
        createdAt: DateTime(2025, 1, 1),
      );

      final map = note.toFirestore();
      expect(map['authorUid'], isNull);
    });

    test('toFirestore converts createdAt to Timestamp', () {
      final note = _makeNote();
      final map = note.toFirestore();

      expect(map['createdAt'], isA<Timestamp>());
    });
  });

  group('ClinicalNote fromFirestore', () {
    test('fromFirestore creates note with all fields', () {
      final doc = FakeDocumentSnapshot('note-1', {
        'authorUid': 'u-1',
        'authorName': 'Dr. Smith',
        'authorAvatarUrl': 'https://example.com/smith.png',
        'content': 'Heart murmur grade 3/6.',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 15, 14, 30)),
      });

      final note = ClinicalNote.fromFirestore(doc);

      expect(note.id, 'note-1');
      expect(note.authorUid, 'u-1');
      expect(note.authorName, 'Dr. Smith');
      expect(note.authorAvatarUrl, 'https://example.com/smith.png');
      expect(note.content, 'Heart murmur grade 3/6.');
      expect(note.createdAt, DateTime(2025, 3, 15, 14, 30));
    });

    test('fromFirestore handles null authorUid', () {
      final doc = FakeDocumentSnapshot('note-2', {
        'authorName': 'Guest',
        'authorAvatarUrl': '',
        'content': 'Test note',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final note = ClinicalNote.fromFirestore(doc);

      expect(note.authorUid, isNull);
    });

    test('fromFirestore defaults missing strings to empty', () {
      final doc = FakeDocumentSnapshot('note-3', {
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final note = ClinicalNote.fromFirestore(doc);

      expect(note.authorName, '');
      expect(note.authorAvatarUrl, '');
      expect(note.content, '');
    });

    test('fromFirestore roundtrips with toFirestore', () {
      final original = _makeNote();
      final map = original.toFirestore();
      final doc = FakeDocumentSnapshot('note-1', map);
      final restored = ClinicalNote.fromFirestore(doc);

      expect(restored.id, 'note-1');
      expect(restored.authorUid, original.authorUid);
      expect(restored.authorName, original.authorName);
      expect(restored.authorAvatarUrl, original.authorAvatarUrl);
      expect(restored.content, original.content);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
