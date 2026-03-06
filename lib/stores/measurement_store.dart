import 'package:flutter/foundation.dart';
import 'package:pet_circle/models/measurement.dart';

final measurementStore = MeasurementStore();

class MeasurementStore extends ChangeNotifier {
  Map<String, List<Measurement>> _measurements = {};

  void seed(Map<String, List<Measurement>> initial) {
    _measurements = {
      for (final entry in initial.entries) entry.key: List.of(entry.value),
    };
    notifyListeners();
  }

  List<Measurement> getMeasurements(String petName) {
    return List.unmodifiable(_measurements[petName] ?? []);
  }

  Measurement? latestForPet(String petName) {
    final list = _measurements[petName];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  void addMeasurement(String petName, Measurement measurement) {
    _measurements.putIfAbsent(petName, () => []);
    _measurements[petName]!.insert(0, measurement);
    notifyListeners();
  }

  void removeMeasurement(String petName, Measurement measurement) {
    final list = _measurements[petName];
    if (list == null) return;
    list.removeWhere((m) =>
        m.bpm == measurement.bpm &&
        m.recordedAt.isAtSameMomentAs(measurement.recordedAt));
    notifyListeners();
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

  int countForPet(String petName) {
    return _measurements[petName]?.length ?? 0;
  }

  Map<String, List<Measurement>> get all => Map.unmodifiable(_measurements);
}
