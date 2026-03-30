import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/services/pet_service.dart';

final measurementStore = MeasurementStore();

class MeasurementStore extends ChangeNotifier {
  Map<String, List<Measurement>> _measurements = {};
  final Map<String, StreamSubscription<List<Measurement>>> _subscriptions = {};

  void seed(Map<String, List<Measurement>> initial) {
    _measurements = {
      for (final entry in initial.entries) entry.key: List.of(entry.value),
    };
    notifyListeners();
  }

  List<Measurement> getMeasurements(String petId) {
    return List.unmodifiable(_measurements[petId] ?? []);
  }

  Measurement? latestForPet(String petId) {
    final list = _measurements[petId];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  Future<void> addMeasurement(String petId, Measurement measurement) async {
    _measurements.putIfAbsent(petId, () => []);
    _measurements[petId]!.insert(0, measurement);
    notifyListeners();

    if (kEnableFirebase) {
      try {
        await PetService.addMeasurement(petId, measurement);
      } catch (e) {
        _measurements[petId]?.remove(measurement);
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> removeMeasurement(String petId, Measurement measurement) async {
    final list = _measurements[petId];
    if (list == null) return;

    final idx = list.indexWhere((m) =>
        m.bpm == measurement.bpm &&
        m.recordedAt.isAtSameMomentAs(measurement.recordedAt));
    if (idx == -1) return;

    list.removeAt(idx);
    notifyListeners();

    if (kEnableFirebase && measurement.id != null) {
      try {
        await PetService.deleteMeasurement(petId, measurement.id!);
      } catch (e) {
        list.insert(idx.clamp(0, list.length), measurement);
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
      _measurements.remove(id);
    }

    for (final id in newIds.difference(currentIds)) {
      _subscriptions[id] = PetService.streamMeasurements(id).listen((list) {
        _measurements[id] = list;
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

  int get totalCount =>
      _measurements.values.fold(0, (sum, list) => sum + list.length);

  int get thisWeekCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    int count = 0;
    for (final list in _measurements.values) {
      count += list.where((m) => m.recordedAt.isAfter(weekAgo)).length;
    }
    return count;
  }

  int countForPet(String petId) {
    return _measurements[petId]?.length ?? 0;
  }

  Map<String, List<Measurement>> get all => Map.unmodifiable(_measurements);
}
