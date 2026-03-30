import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/services/pet_service.dart';

final noteStore = NoteStore();

class NoteStore extends ChangeNotifier {
  Map<String, List<ClinicalNote>> _notes = {};
  final Map<String, StreamSubscription<List<ClinicalNote>>> _subscriptions = {};

  void seed(Map<String, List<ClinicalNote>> initial) {
    _notes = {
      for (final entry in initial.entries) entry.key: List.of(entry.value),
    };
    notifyListeners();
  }

  List<ClinicalNote> getNotes(String petId) {
    return List.unmodifiable(_notes[petId] ?? []);
  }

  Future<void> addNote(String petId, ClinicalNote note) async {
    _notes.putIfAbsent(petId, () => []);
    _notes[petId]!.insert(0, note);
    notifyListeners();

    if (kEnableFirebase) {
      try {
        await PetService.addNote(petId, note);
      } catch (e) {
        _notes[petId]?.remove(note);
        notifyListeners();
        rethrow;
      }
    }
  }

  void subscribeForPets(List<String> petIds) {
    final currentIds = _subscriptions.keys.toSet();
    final newIds = petIds.toSet();

    for (final id in currentIds.difference(newIds)) {
      _subscriptions[id]?.cancel();
      _subscriptions.remove(id);
      _notes.remove(id);
    }

    for (final id in newIds.difference(currentIds)) {
      _subscriptions[id] = PetService.streamNotes(id).listen((list) {
        _notes[id] = list;
        notifyListeners();
      });
    }
  }

  void cancelSubscriptions() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  int countForPet(String petId) {
    return _notes[petId]?.length ?? 0;
  }
}
