import 'package:flutter/foundation.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/services/note_service.dart';

final noteStore = NoteStore();

class NoteStore extends ChangeNotifier {
  Map<String, List<ClinicalNote>> _notes = {};
  List<String> _currentPetIds = [];
  final Set<String> _pendingWritePetIds = {};

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
    _pendingWritePetIds.add(petId);
    notifyListeners();

    if (kEnableFirebase) {
      try {
        await NoteService.add(petId, note);
      } catch (e) {
        _notes[petId]?.remove(note);
        notifyListeners();
        rethrow;
      } finally {
        _pendingWritePetIds.remove(petId);
      }
    } else {
      _pendingWritePetIds.remove(petId);
    }
  }

  /// Fetch notes for the given pet IDs from Firestore.
  Future<void> fetchForPets(List<String> petIds) async {
    final newIds = petIds.toSet();
    _notes.removeWhere((id, _) => !newIds.contains(id));
    _currentPetIds = List.of(petIds);

    final futures = <Future<void>>[];
    for (final id in petIds) {
      if (_pendingWritePetIds.contains(id)) continue;
      futures.add(
        NoteService.fetch(id).then((list) {
          _notes[id] = list;
        }).catchError((Object e) {
          debugPrint('[NoteStore] Failed to fetch for pet $id: $e');
        }),
      );
    }
    await Future.wait(futures);
    notifyListeners();
  }

  /// Re-fetch all notes for the current pet IDs (pull-to-refresh).
  Future<void> refresh() async {
    if (_currentPetIds.isEmpty) return;
    await fetchForPets(_currentPetIds);
  }

  void clearData() {
    _notes.clear();
    _currentPetIds = [];
    notifyListeners();
  }

  int countForPet(String petId) {
    return _notes[petId]?.length ?? 0;
  }
}
