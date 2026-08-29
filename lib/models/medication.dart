import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  const Medication({
    required this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
    this.purpose,
    this.notes,
    this.remindersEnabled = false,
    this.reminderTimes = const [],
    this.isActive = true,
  });

  final String id;

  /// The pet this medication belongs to. Medications are stored privately per
  /// user (users/{uid}/medications), so each doc records its own pet.
  final String petId;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy;
  final String? purpose;
  final String? notes;
  final bool remindersEnabled;

  /// Times of day at which a dose reminder should fire, as canonical 24h
  /// `"HH:mm"` strings. Empty when reminders are off, or when the frequency
  /// has no fixed dose schedule (e.g. "As needed").
  final List<String> reminderTimes;

  final bool isActive;

  /// True when this medication should fire an end-of-course reminder:
  /// it is active, reminders are enabled, and an end date is set.
  bool get hasEndReminder => isActive && remindersEnabled && endDate != null;

  /// True when this medication should fire recurring daily dose reminders.
  bool get hasDoseReminders =>
      isActive && remindersEnabled && reminderTimes.isNotEmpty;

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      if (prescribedBy != null && prescribedBy!.isNotEmpty)
        'prescribedBy': prescribedBy,
      if (purpose != null && purpose!.isNotEmpty) 'purpose': purpose,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'remindersEnabled': remindersEnabled,
      'reminderTimes': reminderTimes,
      'isActive': isActive,
    };
  }

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medication(
      id: doc.id,
      petId: data['petId'] ?? '',
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      frequency: data['frequency'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      prescribedBy: data['prescribedBy'] as String?,
      purpose: data['purpose'] as String?,
      notes: data['notes'] as String?,
      remindersEnabled: data['remindersEnabled'] ?? false,
      reminderTimes: _parseReminderTimes(data['reminderTimes']),
      isActive: data['isActive'] ?? true,
    );
  }

  Medication copyWith({
    String? id,
    String? petId,
    String? name,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    String? prescribedBy,
    String? purpose,
    String? notes,
    bool? remindersEnabled,
    List<String>? reminderTimes,
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      prescribedBy: prescribedBy ?? this.prescribedBy,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      // Never share the incoming list instance — copyWith must yield a value
      // that cannot be mutated through the caller's reference.
      reminderTimes: List<String>.unmodifiable(
        reminderTimes ?? this.reminderTimes,
      ),
      isActive: isActive ?? this.isActive,
    );
  }

  /// Defensive parse of the persisted `reminderTimes` field: tolerates a
  /// missing value, a non-list value, and non-string entries.
  static List<String> _parseReminderTimes(dynamic raw) {
    if (raw is! List) return const [];
    return List<String>.unmodifiable(raw.whereType<String>());
  }
}
