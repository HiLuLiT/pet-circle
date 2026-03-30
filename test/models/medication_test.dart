import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/medication.dart';

Medication _makeMedication({bool isActive = true}) {
  return Medication(
    id: 'med-1',
    name: 'Furosemide',
    dosage: '10mg',
    frequency: 'Twice daily',
    startDate: DateTime(2025, 1, 1),
    endDate: DateTime(2025, 6, 1),
    prescribedBy: 'Dr. Smith',
    purpose: 'Heart failure',
    notes: 'Take with food',
    remindersEnabled: true,
    isActive: isActive,
  );
}

void main() {
  group('Medication copyWith', () {
    test('copyWith creates a new instance', () {
      final original = _makeMedication();
      final copy = original.copyWith(name: 'Enalapril');

      expect(identical(original, copy), isFalse);
      expect(copy.name, 'Enalapril');
      expect(original.name, 'Furosemide');
    });

    test('original is unchanged after copyWith', () {
      final original = _makeMedication();

      original.copyWith(
        dosage: '20mg',
        frequency: 'Once daily',
        isActive: false,
      );

      expect(original.dosage, '10mg');
      expect(original.frequency, 'Twice daily');
      expect(original.isActive, isTrue);
    });

    test('copyWith preserves all fields when no args given', () {
      final original = _makeMedication();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.dosage, original.dosage);
      expect(copy.frequency, original.frequency);
      expect(copy.startDate, original.startDate);
      expect(copy.endDate, original.endDate);
      expect(copy.prescribedBy, original.prescribedBy);
      expect(copy.purpose, original.purpose);
      expect(copy.notes, original.notes);
      expect(copy.remindersEnabled, original.remindersEnabled);
      expect(copy.isActive, original.isActive);
    });
  });

  group('Medication isActive', () {
    test('isActive defaults to true', () {
      final med = Medication(
        id: 'med-x',
        name: 'Test',
        dosage: '5mg',
        frequency: 'Daily',
        startDate: DateTime(2025, 1, 1),
      );

      expect(med.isActive, isTrue);
    });

    test('isActive can be set to false', () {
      final med = _makeMedication(isActive: false);
      expect(med.isActive, isFalse);
    });

    test('toggling isActive via copyWith works', () {
      final active = _makeMedication(isActive: true);
      final inactive = active.copyWith(isActive: false);

      expect(active.isActive, isTrue);
      expect(inactive.isActive, isFalse);
    });
  });

  group('Medication clearEndDate', () {
    test('clearEndDate removes endDate', () {
      final withEnd = _makeMedication();
      expect(withEnd.endDate, isNotNull);

      final cleared = withEnd.copyWith(clearEndDate: true);
      expect(cleared.endDate, isNull);
    });

    test('clearEndDate false preserves existing endDate', () {
      final med = _makeMedication();
      final copy = med.copyWith(clearEndDate: false);

      expect(copy.endDate, med.endDate);
    });
  });

  group('Medication optional fields', () {
    test('optional fields can be null', () {
      final med = Medication(
        id: 'med-minimal',
        name: 'Basic',
        dosage: '1mg',
        frequency: 'Daily',
        startDate: DateTime(2025, 1, 1),
      );

      expect(med.endDate, isNull);
      expect(med.prescribedBy, isNull);
      expect(med.purpose, isNull);
      expect(med.notes, isNull);
      expect(med.remindersEnabled, isFalse);
    });
  });
}
