import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/utils/health_report_builder.dart';

Pet _makePet({String? diagnosis}) {
  return Pet(
    name: 'Princess',
    breedAndAge: 'Labrador, 4 years',
    imageUrl: '',
    statusLabel: 'Normal',
    statusColorHex: 0xFF75ACFF,
    latestMeasurement: Measurement(bpm: 20, recordedAt: DateTime(2026, 1, 1)),
    careCircle: const [],
    diagnosis: diagnosis,
  );
}

void main() {
  group('buildFullRecordCsv', () {
    test('includes all four sections with data', () {
      final csv = buildFullRecordCsv(
        pet: _makePet(diagnosis: 'Mitral valve disease'),
        measurements: [
          Measurement(bpm: 22, recordedAt: DateTime(2026, 1, 1, 8)),
          Measurement(bpm: 28, recordedAt: DateTime(2026, 1, 2, 8)),
        ],
        medications: [
          Medication(
            id: 'm1',
            petId: 'p1',
            name: 'Pimobendan',
            dosage: '5mg',
            frequency: 'Twice daily',
            startDate: DateTime(2026, 1, 1),
            isActive: true,
          ),
        ],
        notes: [
          ClinicalNote(
            id: 'n1',
            authorName: 'Dr. Smith',
            authorAvatarUrl: '',
            content: 'Doing well',
            createdAt: DateTime(2026, 1, 3),
          ),
        ],
      );

      expect(csv, contains('# Profile'));
      expect(csv, contains('Princess'));
      expect(csv, contains('Mitral valve disease'));

      expect(csv, contains('# Measurements'));
      expect(csv, contains('Date,BPM'));
      expect(csv, contains(',22'));
      expect(csv, contains(',28'));

      expect(csv, contains('# Medications'));
      expect(csv, contains('Pimobendan'));
      expect(csv, contains('5mg'));
      expect(csv, contains('Ongoing'));

      expect(csv, contains('# Notes'));
      expect(csv, contains('Dr. Smith'));
      expect(csv, contains('Doing well'));
    });

    test('produces headers-only sections for a pet with no recorded data', () {
      final csv = buildFullRecordCsv(
        pet: _makePet(),
        measurements: const [],
        medications: const [],
        notes: const [],
      );

      expect(csv, contains('# Profile'));
      expect(csv, contains('# Measurements'));
      expect(csv, contains('Date,BPM'));
      expect(csv, contains('# Medications'));
      expect(csv, contains('# Notes'));
      // No data rows beyond the headers for the empty sections.
      expect(csv, isNot(contains('null')));
    });

    test('omits diagnosis field content when the pet has none', () {
      final csv = buildFullRecordCsv(
        pet: _makePet(),
        measurements: const [],
        medications: const [],
        notes: const [],
      );

      final profileLine = csv.split('\n')[2];
      expect(profileLine, 'Princess,"Labrador, 4 years",');
    });

    test('escapes commas, quotes, and newlines in medication fields', () {
      final csv = buildFullRecordCsv(
        pet: _makePet(),
        measurements: const [],
        medications: [
          Medication(
            id: 'm1',
            petId: 'p1',
            name: 'Med, with comma',
            dosage: '5mg',
            frequency: 'Once daily',
            startDate: DateTime(2026, 1, 1),
            notes: 'Give "with food"',
          ),
        ],
        notes: const [],
      );

      expect(csv, contains('"Med, with comma"'));
      expect(csv, contains('"Give ""with food"""'));
    });

    test('escapes commas and quotes in clinical note content', () {
      final csv = buildFullRecordCsv(
        pet: _makePet(),
        measurements: const [],
        medications: const [],
        notes: [
          ClinicalNote(
            id: 'n1',
            authorName: 'Dr. A, DVM',
            authorAvatarUrl: '',
            content: 'Said "improving"',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
      );

      expect(csv, contains('"Dr. A, DVM"'));
      expect(csv, contains('"Said ""improving"""'));
    });

    test('marks inactive medications as Completed', () {
      final csv = buildFullRecordCsv(
        pet: _makePet(),
        measurements: const [],
        medications: [
          Medication(
            id: 'm1',
            petId: 'p1',
            name: 'Old Med',
            dosage: '1mg',
            frequency: 'Once',
            startDate: DateTime(2026, 1, 1),
            isActive: false,
          ),
        ],
        notes: const [],
      );

      expect(csv, contains('Completed'));
      expect(csv, isNot(contains('Ongoing')));
    });
  });
}
