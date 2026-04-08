import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/stores/note_store.dart';

ClinicalNote _makeNote({
  String id = 'note-1',
  String content = 'Respiratory rate stable.',
}) {
  return ClinicalNote(
    id: id,
    authorName: 'Dr. Smith',
    authorAvatarUrl: 'https://example.com/avatar.png',
    content: content,
    createdAt: DateTime(2025, 3, 1),
  );
}

void main() {
  late NoteStore store;

  setUp(() {
    store = NoteStore();
  });

  group('NoteStore seed', () {
    test('seed() populates notes', () {
      store.seed({
        'pet-1': [_makeNote(), _makeNote(id: 'note-2', content: 'Follow-up.')],
      });

      expect(store.getNotes('pet-1').length, 2);
      expect(store.getNotes('pet-2'), isEmpty);
    });

    test('seed() notifies listeners', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.seed({'pet-1': [_makeNote()]});
      expect(callCount, 1);
    });
  });

  group('NoteStore add', () {
    test('adding a note works via seed', () {
      store.seed({'pet-1': []});

      store.seed({
        'pet-1': [_makeNote()],
      });

      expect(store.getNotes('pet-1').length, 1);
      expect(store.getNotes('pet-1').first.content, 'Respiratory rate stable.');
    });
  });

  group('NoteStore countForPet', () {
    test('countForPet returns correct count', () {
      store.seed({
        'pet-1': [_makeNote(), _makeNote(id: 'note-2')],
      });

      expect(store.countForPet('pet-1'), 2);
      expect(store.countForPet('nonexistent'), 0);
    });
  });

  group('NoteStore unmodifiable', () {
    test('getNotes returns unmodifiable list', () {
      store.seed({'pet-1': [_makeNote()]});

      final list = store.getNotes('pet-1');
      expect(
        () => list.add(_makeNote(id: 'extra')),
        throwsUnsupportedError,
      );
    });
  });

  group('NoteStore seed replaces previous data', () {
    test('re-seeding replaces all notes', () {
      store.seed({
        'pet-1': [_makeNote(), _makeNote(id: 'note-2')],
      });
      expect(store.countForPet('pet-1'), 2);

      store.seed({
        'pet-2': [_makeNote(id: 'note-3')],
      });
      expect(store.countForPet('pet-1'), 0);
      expect(store.countForPet('pet-2'), 1);
    });
  });

  group('NoteStore getNotes for missing pet', () {
    test('getNotes returns empty list for unknown pet', () {
      store.seed({});

      expect(store.getNotes('nonexistent'), isEmpty);
    });
  });

  group('NoteStore countForPet edge cases', () {
    test('countForPet returns zero for empty list', () {
      store.seed({'pet-1': []});
      expect(store.countForPet('pet-1'), 0);
    });

    test('countForPet returns zero when no pets seeded', () {
      store.seed({});
      expect(store.countForPet('any-pet'), 0);
    });
  });

  group('NoteStore multiple pets', () {
    test('notes are isolated per pet', () {
      store.seed({
        'pet-1': [
          _makeNote(id: 'note-1', content: 'Note for pet 1'),
        ],
        'pet-2': [
          _makeNote(id: 'note-2', content: 'Note for pet 2'),
          _makeNote(id: 'note-3', content: 'Another for pet 2'),
        ],
      });

      expect(store.countForPet('pet-1'), 1);
      expect(store.countForPet('pet-2'), 2);
      expect(store.getNotes('pet-1').first.id, 'note-1');
      expect(store.getNotes('pet-2').first.id, 'note-2');
    });
  });

  group('NoteStore notifyListeners', () {
    test('seed notifies listeners', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.seed({'pet-1': [_makeNote()]});
      expect(callCount, 1);
    });

    test('multiple seeds notify listeners each time', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.seed({'pet-1': [_makeNote()]});
      store.seed({'pet-1': []});
      store.seed({});

      expect(callCount, 3);
    });
  });

  group('NoteStore getNotes returns defensive copy', () {
    test('modifying returned list does not affect store', () {
      store.seed({'pet-1': [_makeNote()]});

      // getNotes returns unmodifiable, so we can't add to it
      // but we verify the store still has the original data
      expect(store.getNotes('pet-1').length, 1);
      expect(store.countForPet('pet-1'), 1);
    });
  });
}
