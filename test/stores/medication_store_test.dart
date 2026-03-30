import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/stores/medication_store.dart';

Medication _makeMedication({
  String id = 'med-1',
  String name = 'Furosemide',
  bool isActive = true,
}) {
  return Medication(
    id: id,
    name: name,
    dosage: '10mg',
    frequency: 'Twice daily',
    startDate: DateTime(2025, 1, 1),
    isActive: isActive,
  );
}

void main() {
  late MedicationStore store;

  setUp(() {
    store = MedicationStore();
  });

  group('MedicationStore seed', () {
    test('seed() populates medications', () {
      store.seed({
        'pet-1': [_makeMedication(), _makeMedication(id: 'med-2', name: 'Aspirin')],
        'pet-2': [_makeMedication(id: 'med-3', name: 'Enalapril')],
      });

      expect(store.getMedications('pet-1').length, 2);
      expect(store.getMedications('pet-2').length, 1);
      expect(store.getMedications('pet-3'), isEmpty);
    });

    test('seed() notifies listeners', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.seed({'pet-1': [_makeMedication()]});
      expect(callCount, 1);
    });
  });

  group('MedicationStore add', () {
    test('adding a medication works via seed', () {
      store.seed({'pet-1': []});

      // Re-seed with the added medication to simulate local add
      store.seed({
        'pet-1': [_makeMedication()],
      });

      expect(store.getMedications('pet-1').length, 1);
      expect(store.getMedications('pet-1').first.name, 'Furosemide');
    });
  });

  group('MedicationStore getActiveMedications', () {
    test('filters to only active medications', () {
      store.seed({
        'pet-1': [
          _makeMedication(id: 'med-1', isActive: true),
          _makeMedication(id: 'med-2', name: 'Inactive', isActive: false),
        ],
      });

      final active = store.getActiveMedications('pet-1');
      expect(active.length, 1);
      expect(active.first.name, 'Furosemide');
    });
  });

  group('MedicationStore immutability', () {
    test('updating a medication preserves immutability (new object via copyWith)', () {
      final original = _makeMedication();
      final updated = original.copyWith(dosage: '20mg');

      expect(original.dosage, '10mg');
      expect(updated.dosage, '20mg');
      expect(identical(original, updated), isFalse);
    });

    test('getMedications returns unmodifiable list', () {
      store.seed({'pet-1': [_makeMedication()]});

      final list = store.getMedications('pet-1');
      expect(
        () => list.add(_makeMedication(id: 'extra')),
        throwsUnsupportedError,
      );
    });
  });

  group('MedicationStore copyWith on Medication', () {
    test('copyWith creates new Medication with updated fields', () {
      final med = _makeMedication();
      final toggled = med.copyWith(isActive: false);

      expect(med.isActive, true);
      expect(toggled.isActive, false);
      expect(toggled.name, med.name);
      expect(toggled.dosage, med.dosage);
    });

    test('clearEndDate works in copyWith', () {
      final med = _makeMedication().copyWith(endDate: DateTime(2025, 6, 1));
      expect(med.endDate, isNotNull);

      final cleared = med.copyWith(clearEndDate: true);
      expect(cleared.endDate, isNull);
    });
  });
}
