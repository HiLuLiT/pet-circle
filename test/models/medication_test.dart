import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/medication.dart';

import '../helpers/fake_document_snapshot.dart';

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

  group('Medication construction', () {
    test('remindersEnabled defaults to false', () {
      final med = Medication(
        id: 'med-def',
        name: 'Test',
        dosage: '1mg',
        frequency: 'Daily',
        startDate: DateTime(2025, 1, 1),
      );

      expect(med.remindersEnabled, isFalse);
    });

    test('all required fields are set correctly', () {
      final med = _makeMedication();

      expect(med.id, 'med-1');
      expect(med.name, 'Furosemide');
      expect(med.dosage, '10mg');
      expect(med.frequency, 'Twice daily');
      expect(med.startDate, DateTime(2025, 1, 1));
    });
  });

  group('Medication toFirestore', () {
    test('toFirestore includes all required fields', () {
      final med = _makeMedication();
      final map = med.toFirestore();

      expect(map['name'], 'Furosemide');
      expect(map['dosage'], '10mg');
      expect(map['frequency'], 'Twice daily');
      expect(map['remindersEnabled'], isTrue);
      expect(map['isActive'], isTrue);
      expect(map.containsKey('startDate'), isTrue);
    });

    test('toFirestore does not include id', () {
      final med = _makeMedication();
      final map = med.toFirestore();

      expect(map.containsKey('id'), isFalse);
    });

    test('toFirestore includes optional fields when set', () {
      final med = _makeMedication();
      final map = med.toFirestore();

      expect(map['prescribedBy'], 'Dr. Smith');
      expect(map['purpose'], 'Heart failure');
      expect(map['notes'], 'Take with food');
      expect(map.containsKey('endDate'), isTrue);
    });

    test('toFirestore omits optional fields when null', () {
      final med = Medication(
        id: 'med-min',
        name: 'Basic',
        dosage: '1mg',
        frequency: 'Daily',
        startDate: DateTime(2025, 1, 1),
      );
      final map = med.toFirestore();

      expect(map.containsKey('endDate'), isFalse);
      expect(map.containsKey('prescribedBy'), isFalse);
      expect(map.containsKey('purpose'), isFalse);
      expect(map.containsKey('notes'), isFalse);
    });

    test('toFirestore omits optional strings when empty', () {
      final med = Medication(
        id: 'med-empty',
        name: 'Test',
        dosage: '1mg',
        frequency: 'Daily',
        startDate: DateTime(2025, 1, 1),
        prescribedBy: '',
        purpose: '',
        notes: '',
      );
      final map = med.toFirestore();

      expect(map.containsKey('prescribedBy'), isFalse);
      expect(map.containsKey('purpose'), isFalse);
      expect(map.containsKey('notes'), isFalse);
    });

    test('toFirestore converts startDate to Timestamp', () {
      final med = _makeMedication();
      final map = med.toFirestore();

      expect(map['startDate'], isA<Timestamp>());
    });

    test('toFirestore converts endDate to Timestamp', () {
      final med = _makeMedication();
      final map = med.toFirestore();

      expect(map['endDate'], isA<Timestamp>());
    });
  });

  group('Medication fromFirestore', () {
    test('fromFirestore creates Medication with all fields', () {
      final doc = FakeDocumentSnapshot('med-1', {
        'name': 'Furosemide',
        'dosage': '10mg',
        'frequency': 'Twice daily',
        'startDate': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'endDate': Timestamp.fromDate(DateTime(2025, 6, 1)),
        'prescribedBy': 'Dr. Smith',
        'purpose': 'Heart failure',
        'notes': 'Take with food',
        'remindersEnabled': true,
        'isActive': true,
      });

      final med = Medication.fromFirestore(doc);

      expect(med.id, 'med-1');
      expect(med.name, 'Furosemide');
      expect(med.dosage, '10mg');
      expect(med.frequency, 'Twice daily');
      expect(med.startDate, DateTime(2025, 1, 1));
      expect(med.endDate, DateTime(2025, 6, 1));
      expect(med.prescribedBy, 'Dr. Smith');
      expect(med.purpose, 'Heart failure');
      expect(med.notes, 'Take with food');
      expect(med.remindersEnabled, isTrue);
      expect(med.isActive, isTrue);
    });

    test('fromFirestore handles missing optional fields', () {
      final doc = FakeDocumentSnapshot('med-2', {
        'name': 'Basic Med',
        'dosage': '5mg',
        'frequency': 'Daily',
        'startDate': Timestamp.fromDate(DateTime(2025, 3, 1)),
      });

      final med = Medication.fromFirestore(doc);

      expect(med.id, 'med-2');
      expect(med.name, 'Basic Med');
      expect(med.endDate, isNull);
      expect(med.prescribedBy, isNull);
      expect(med.purpose, isNull);
      expect(med.notes, isNull);
      expect(med.remindersEnabled, isFalse);
      expect(med.isActive, isTrue);
    });

    test('fromFirestore defaults name/dosage/frequency to empty string', () {
      final doc = FakeDocumentSnapshot('med-3', {
        'startDate': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final med = Medication.fromFirestore(doc);

      expect(med.name, '');
      expect(med.dosage, '');
      expect(med.frequency, '');
    });

    test('fromFirestore roundtrips with toFirestore', () {
      final original = _makeMedication();
      final map = original.toFirestore();
      final doc = FakeDocumentSnapshot('med-1', map);
      final restored = Medication.fromFirestore(doc);

      expect(restored.id, 'med-1');
      expect(restored.name, original.name);
      expect(restored.dosage, original.dosage);
      expect(restored.frequency, original.frequency);
      expect(restored.startDate, original.startDate);
      expect(restored.endDate, original.endDate);
      expect(restored.prescribedBy, original.prescribedBy);
      expect(restored.purpose, original.purpose);
      expect(restored.notes, original.notes);
      expect(restored.remindersEnabled, original.remindersEnabled);
      expect(restored.isActive, original.isActive);
    });
  });

  group('Medication copyWith individual fields', () {
    test('copyWith can update each field independently', () {
      final original = _makeMedication();

      expect(original.copyWith(id: 'new-id').id, 'new-id');
      expect(original.copyWith(name: 'New Name').name, 'New Name');
      expect(original.copyWith(dosage: '20mg').dosage, '20mg');
      expect(original.copyWith(frequency: 'Once daily').frequency, 'Once daily');
      expect(
        original.copyWith(startDate: DateTime(2026, 1, 1)).startDate,
        DateTime(2026, 1, 1),
      );
      expect(
        original.copyWith(endDate: DateTime(2026, 6, 1)).endDate,
        DateTime(2026, 6, 1),
      );
      expect(original.copyWith(prescribedBy: 'Dr. Jones').prescribedBy, 'Dr. Jones');
      expect(original.copyWith(purpose: 'New purpose').purpose, 'New purpose');
      expect(original.copyWith(notes: 'New notes').notes, 'New notes');
      expect(original.copyWith(remindersEnabled: false).remindersEnabled, isFalse);
      expect(original.copyWith(isActive: false).isActive, isFalse);
    });
  });

  // ── Supply tracking tests ──────────────────────────────────────────

  group('Medication supply tracking', () {
    Medication makeMed({
      String frequency = 'Twice daily',
      int? totalSupply = 60,
      DateTime? supplyStartDate,
      int? restockLeadDays = 5,
    }) {
      return Medication(
        id: 'm1',
        name: 'Furosemide',
        dosage: '12.5mg',
        frequency: frequency,
        startDate: DateTime(2026, 1, 1),
        totalSupply: totalSupply,
        supplyStartDate: supplyStartDate,
        restockLeadDays: restockLeadDays,
      );
    }

    test('dosesPerDay maps frequency', () {
      expect(makeMed(frequency: 'Once daily').dosesPerDay, 1);
      expect(makeMed(frequency: 'Twice daily').dosesPerDay, 2);
      expect(makeMed(frequency: 'As needed').dosesPerDay, isNull);
    });

    test('hasSupplyTracking requires total, start date, and a daily rate', () {
      expect(makeMed(supplyStartDate: DateTime(2026, 1, 1)).hasSupplyTracking,
          isTrue);
      expect(makeMed(supplyStartDate: null).hasSupplyTracking, isFalse);
      expect(
          makeMed(totalSupply: null, supplyStartDate: DateTime(2026, 1, 1))
              .hasSupplyTracking,
          isFalse);
      expect(
          makeMed(frequency: 'As needed', supplyStartDate: DateTime(2026, 1, 1))
              .hasSupplyTracking,
          isFalse);
    });

    test('remainingDoses decreases with elapsed days and clamps at 0', () {
      final start = DateTime.now().subtract(const Duration(days: 5));
      // twice daily, 60 doses, 5 days elapsed => 60 - 10 = 50
      expect(makeMed(totalSupply: 60, supplyStartDate: start).remainingDoses, 50);
      // fully depleted clamps to 0
      final old = DateTime.now().subtract(const Duration(days: 100));
      expect(makeMed(totalSupply: 60, supplyStartDate: old).remainingDoses, 0);
    });

    test('runOutDate = start + ceil(total / dosesPerDay) days', () {
      final start = DateTime(2026, 1, 1);
      // 60 / 2 = 30 days
      expect(makeMed(totalSupply: 60, supplyStartDate: start).runOutDate,
          DateTime(2026, 1, 31));
      // 5 / 2 = 2.5 -> ceil 3 days
      expect(makeMed(totalSupply: 5, supplyStartDate: start).runOutDate,
          DateTime(2026, 1, 4));
    });

    test('restockDate = runOutDate - restockLeadDays', () {
      final start = DateTime(2026, 1, 1);
      final med =
          makeMed(totalSupply: 60, supplyStartDate: start, restockLeadDays: 5);
      expect(med.restockDate, DateTime(2026, 1, 26));
    });

    test('needsRestock true once within the lead window', () {
      final soon = DateTime.now().subtract(const Duration(days: 28));
      // twice daily, 60 doses -> runs out in ~2 days, lead 5 -> already in window
      expect(makeMed(totalSupply: 60, supplyStartDate: soon).needsRestock,
          isTrue);
      final fresh = DateTime.now();
      expect(makeMed(totalSupply: 60, supplyStartDate: fresh).needsRestock,
          isFalse);
    });

    test('fromFirestore falls back to startDate when supplyStartDate missing',
        () {
      final doc = FakeDocumentSnapshot('m1', {
        'name': 'Med',
        'dosage': '1mg',
        'frequency': 'Once daily',
        'startDate': Timestamp.fromDate(DateTime(2026, 2, 1)),
        'totalSupply': 30,
        // no supplyStartDate, plus legacy fields that must be ignored
        'currentSupply': 12,
        'lowSupplyThreshold': 7,
      });
      final med = Medication.fromFirestore(doc);
      expect(med.totalSupply, 30);
      expect(med.supplyStartDate, DateTime(2026, 2, 1));
      expect(med.restockLeadDays, isNull);
    });

    test('toFirestore includes new supply fields when set', () {
      final med =
          makeMed(supplyStartDate: DateTime(2026, 1, 1), restockLeadDays: 5);
      final map = med.toFirestore();

      expect(map['totalSupply'], 60);
      expect(map['supplyStartDate'], isA<Timestamp>());
      expect(map['restockLeadDays'], 5);
    });

    test('supply fields roundtrip through toFirestore/fromFirestore', () {
      final original =
          makeMed(supplyStartDate: DateTime(2026, 1, 1), restockLeadDays: 5);
      final map = original.toFirestore();
      final doc = FakeDocumentSnapshot('m1', map);
      final restored = Medication.fromFirestore(doc);

      expect(restored.totalSupply, original.totalSupply);
      expect(restored.supplyStartDate, original.supplyStartDate);
      expect(restored.restockLeadDays, original.restockLeadDays);
    });

    test('copyWith clearSupplyStartDate disables tracking', () {
      final med = makeMed(supplyStartDate: DateTime(2026, 1, 1));
      final cleared = med.copyWith(clearSupplyStartDate: true);
      expect(cleared.supplyStartDate, isNull);
      expect(cleared.hasSupplyTracking, isFalse);
    });
  });
}
