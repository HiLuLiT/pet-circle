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
    Medication _makeWithSupply({
      int totalSupply = 60,
      int currentSupply = 45,
      int lowSupplyThreshold = 7,
    }) {
      return Medication(
        id: 'med-supply',
        name: 'Pimobendan',
        dosage: '5mg',
        frequency: 'Once daily',
        startDate: DateTime(2025, 1, 1),
        totalSupply: totalSupply,
        currentSupply: currentSupply,
        lowSupplyThreshold: lowSupplyThreshold,
      );
    }

    test('hasSupplyTracking is true when both total and current are set', () {
      final med = _makeWithSupply();
      expect(med.hasSupplyTracking, isTrue);
    });

    test('hasSupplyTracking is false when fields are null', () {
      final med = _makeMedication();
      expect(med.hasSupplyTracking, isFalse);
    });

    test('hasSupplyTracking is false when only totalSupply is set', () {
      final med = Medication(
        id: 'med-partial',
        name: 'Test',
        dosage: '1mg',
        frequency: 'Daily',
        startDate: DateTime(2025, 1, 1),
        totalSupply: 60,
      );
      expect(med.hasSupplyTracking, isFalse);
    });

    test('isLowSupply is true when currentSupply <= threshold', () {
      final med = _makeWithSupply(currentSupply: 7, lowSupplyThreshold: 7);
      expect(med.isLowSupply, isTrue);
    });

    test('isLowSupply is true when currentSupply < threshold', () {
      final med = _makeWithSupply(currentSupply: 3, lowSupplyThreshold: 7);
      expect(med.isLowSupply, isTrue);
    });

    test('isLowSupply is false when currentSupply > threshold', () {
      final med = _makeWithSupply(currentSupply: 45, lowSupplyThreshold: 7);
      expect(med.isLowSupply, isFalse);
    });

    test('isLowSupply uses default threshold of 7 when not set', () {
      final med = Medication(
        id: 'med-default-thresh',
        name: 'Test',
        dosage: '1mg',
        frequency: 'Daily',
        startDate: DateTime(2025, 1, 1),
        totalSupply: 60,
        currentSupply: 7,
      );
      expect(med.isLowSupply, isTrue);
    });

    test('isLowSupply is false when supply tracking disabled', () {
      final med = _makeMedication();
      expect(med.isLowSupply, isFalse);
    });

    test('copyWith updates supply fields', () {
      final med = _makeWithSupply();
      final updated = med.copyWith(currentSupply: 10);

      expect(updated.currentSupply, 10);
      expect(updated.totalSupply, 60); // preserved
      expect(updated.lowSupplyThreshold, 7); // preserved
    });

    test('copyWith clearTotalSupply removes totalSupply', () {
      final med = _makeWithSupply();
      final cleared = med.copyWith(clearTotalSupply: true);

      expect(cleared.totalSupply, isNull);
      expect(cleared.hasSupplyTracking, isFalse);
    });

    test('copyWith clearCurrentSupply removes currentSupply', () {
      final med = _makeWithSupply();
      final cleared = med.copyWith(clearCurrentSupply: true);

      expect(cleared.currentSupply, isNull);
      expect(cleared.hasSupplyTracking, isFalse);
    });

    test('copyWith clearLowSupplyThreshold removes threshold', () {
      final med = _makeWithSupply();
      final cleared = med.copyWith(clearLowSupplyThreshold: true);

      expect(cleared.lowSupplyThreshold, isNull);
    });

    test('toFirestore includes supply fields when set', () {
      final med = _makeWithSupply();
      final map = med.toFirestore();

      expect(map['totalSupply'], 60);
      expect(map['currentSupply'], 45);
      expect(map['lowSupplyThreshold'], 7);
    });

    test('toFirestore omits supply fields when null', () {
      final med = _makeMedication();
      final map = med.toFirestore();

      expect(map.containsKey('totalSupply'), isFalse);
      expect(map.containsKey('currentSupply'), isFalse);
      expect(map.containsKey('lowSupplyThreshold'), isFalse);
    });

    test('fromFirestore reads supply fields', () {
      final doc = FakeDocumentSnapshot('med-supply', {
        'name': 'Pimobendan',
        'dosage': '5mg',
        'frequency': 'Once daily',
        'startDate': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'totalSupply': 60,
        'currentSupply': 45,
        'lowSupplyThreshold': 7,
      });

      final med = Medication.fromFirestore(doc);

      expect(med.totalSupply, 60);
      expect(med.currentSupply, 45);
      expect(med.lowSupplyThreshold, 7);
      expect(med.hasSupplyTracking, isTrue);
    });

    test('fromFirestore handles missing supply fields', () {
      final doc = FakeDocumentSnapshot('med-no-supply', {
        'name': 'Basic',
        'dosage': '1mg',
        'frequency': 'Daily',
        'startDate': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final med = Medication.fromFirestore(doc);

      expect(med.totalSupply, isNull);
      expect(med.currentSupply, isNull);
      expect(med.lowSupplyThreshold, isNull);
      expect(med.hasSupplyTracking, isFalse);
    });

    test('supply fields roundtrip through toFirestore/fromFirestore', () {
      final original = _makeWithSupply();
      final map = original.toFirestore();
      final doc = FakeDocumentSnapshot('med-supply', map);
      final restored = Medication.fromFirestore(doc);

      expect(restored.totalSupply, original.totalSupply);
      expect(restored.currentSupply, original.currentSupply);
      expect(restored.lowSupplyThreshold, original.lowSupplyThreshold);
    });
  });
}
