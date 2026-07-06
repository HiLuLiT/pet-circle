import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/models/pet.dart';

String _csvEscape(String? value) {
  if (value == null || value.isEmpty) return '';
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

String _fmtDate(DateTime? d) {
  if (d == null) return '';
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Builds a single sectioned CSV covering a pet's full health record:
/// profile, all measurements, all medications, and all clinical notes.
///
/// Reuses the escaping/format already proven by the medication and trends
/// screen exports (`lib/screens/medication/medication_screen.dart`,
/// `lib/screens/trends/trends_screen.dart`).
String buildFullRecordCsv({
  required Pet pet,
  required List<Measurement> measurements,
  required List<Medication> medications,
  required List<ClinicalNote> notes,
}) {
  final buffer = StringBuffer();

  buffer.writeln('# Profile');
  buffer.writeln('Name,Breed/Age,Diagnosis');
  buffer.writeln([
    _csvEscape(pet.name),
    _csvEscape(pet.breedAndAge),
    _csvEscape(pet.diagnosis),
  ].join(','));
  buffer.writeln();

  buffer.writeln('# Measurements');
  buffer.writeln('Date,BPM');
  for (final m in measurements) {
    buffer.writeln('${m.recordedAt.toIso8601String()},${m.bpm}');
  }
  buffer.writeln();

  buffer.writeln('# Medications');
  buffer.writeln(
      'Medication,Dosage,Frequency,Start Date,End Date,Status,Prescribed By,Purpose,Notes');
  for (final m in medications) {
    final status = m.isActive ? 'Ongoing' : 'Completed';
    buffer.writeln([
      _csvEscape(m.name),
      _csvEscape(m.dosage),
      _csvEscape(m.frequency),
      _fmtDate(m.startDate),
      _fmtDate(m.endDate),
      status,
      _csvEscape(m.prescribedBy),
      _csvEscape(m.purpose),
      _csvEscape(m.notes),
    ].join(','));
  }
  buffer.writeln();

  buffer.writeln('# Notes');
  buffer.writeln('Date,Author,Content');
  for (final n in notes) {
    buffer.writeln([
      _fmtDate(n.createdAt),
      _csvEscape(n.authorName),
      _csvEscape(n.content),
    ].join(','));
  }

  return buffer.toString().trimRight();
}
