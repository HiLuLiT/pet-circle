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
}
