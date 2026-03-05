import 'package:flutter/foundation.dart';
import 'package:pet_circle/models/clinical_note.dart';

final noteStore = NoteStore();

class NoteStore extends ChangeNotifier {
  Map<String, List<ClinicalNote>> _notes = {};

  void seed(Map<String, List<ClinicalNote>> initial) {
    _notes = {
      for (final entry in initial.entries) entry.key: List.of(entry.value),
    };
    notifyListeners();
  }

  List<ClinicalNote> getNotes(String petName) {
    return List.unmodifiable(_notes[petName] ?? []);
  }

  void addNote(String petName, ClinicalNote note) {
    _notes.putIfAbsent(petName, () => []);
    _notes[petName]!.insert(0, note);
    notifyListeners();
  }

  int countForPet(String petName) {
    return _notes[petName]?.length ?? 0;
  }
}
