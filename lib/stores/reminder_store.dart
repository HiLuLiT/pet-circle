import 'package:flutter/foundation.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/reminder.dart';
import 'package:pet_circle/services/pet_service.dart';

final reminderStore = ReminderStore();

class ReminderStore extends ChangeNotifier {
  Map<String, List<Reminder>> _reminders = {};
  List<String> _currentPetIds = [];
  final Set<String> _pendingWritePetIds = {};

  void seed(Map<String, List<Reminder>> initial) {
    _reminders = {
      for (final entry in initial.entries) entry.key: List.of(entry.value),
    };
    notifyListeners();
  }

  List<Reminder> getReminders(String petId) {
    return List.unmodifiable(_reminders[petId] ?? []);
  }

  Future<void> addReminder(String petId, Reminder reminder) async {
    _reminders.putIfAbsent(petId, () => []);
    _reminders[petId]!.add(reminder);
    _pendingWritePetIds.add(petId);
    notifyListeners();

    if (kEnableFirebase) {
      try {
        // Firestore assigns its own document ID on add() and ignores the
        // client-generated placeholder id on [reminder]. Patch the local
        // entry with the real ID once the write completes, so a subsequent
        // update/delete (which addresses the doc by ID) targets the
        // document that actually exists in Firestore instead of silently
        // no-op'ing (delete) or throwing not-found (update).
        final realId = await PetService.addReminder(petId, reminder);
        final list = _reminders[petId];
        final idx = list?.indexOf(reminder) ?? -1;
        if (idx != -1) {
          list![idx] = reminder.copyWith(id: realId);
          notifyListeners();
        }
      } catch (e) {
        _reminders[petId]?.remove(reminder);
        notifyListeners();
        rethrow;
      } finally {
        _pendingWritePetIds.remove(petId);
      }
    } else {
      _pendingWritePetIds.remove(petId);
    }
  }

  Future<void> updateReminder(
      String petId, String reminderId, Reminder updated) async {
    final list = _reminders[petId];
    if (list == null) return;
    final idx = list.indexWhere((r) => r.id == reminderId);
    if (idx == -1) return;
    final previous = list[idx];
    list[idx] = updated;
    _pendingWritePetIds.add(petId);
    notifyListeners();

    if (kEnableFirebase) {
      try {
        await PetService.updateReminder(
            petId, reminderId, updated.toFirestore());
      } catch (e) {
        list[idx] = previous;
        notifyListeners();
        rethrow;
      } finally {
        _pendingWritePetIds.remove(petId);
      }
    } else {
      _pendingWritePetIds.remove(petId);
    }
  }

  Future<void> removeReminder(String petId, String reminderId) async {
    final list = _reminders[petId];
    final idx = list?.indexWhere((r) => r.id == reminderId) ?? -1;
    final removed = (list != null && idx != -1) ? list.removeAt(idx) : null;
    if (removed != null) {
      _pendingWritePetIds.add(petId);
      notifyListeners();
    }

    if (kEnableFirebase) {
      try {
        await PetService.deleteReminder(petId, reminderId);
      } catch (e) {
        if (removed != null && list != null) {
          list.insert(idx.clamp(0, list.length), removed);
          notifyListeners();
        }
        rethrow;
      } finally {
        _pendingWritePetIds.remove(petId);
      }
    } else {
      _pendingWritePetIds.remove(petId);
    }
  }

  /// Fetch reminders for the given pet IDs from Firestore.
  Future<void> fetchForPets(List<String> petIds) async {
    final newIds = petIds.toSet();
    _reminders.removeWhere((id, _) => !newIds.contains(id));
    _currentPetIds = List.of(petIds);

    final futures = <Future<void>>[];
    for (final id in petIds) {
      if (_pendingWritePetIds.contains(id)) continue;
      futures.add(
        PetService.fetchReminders(id).then((list) {
          _reminders[id] = list;
        }).catchError((Object e) {
          debugPrint('[ReminderStore] Failed to fetch for pet $id: $e');
        }),
      );
    }
    await Future.wait(futures);
    notifyListeners();
  }

  /// Re-fetch all reminders for the current pet IDs (pull-to-refresh).
  Future<void> refresh() async {
    if (_currentPetIds.isEmpty) return;
    await fetchForPets(_currentPetIds);
  }

  void clearData() {
    _reminders.clear();
    _currentPetIds = [];
    notifyListeners();
  }
}
