import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
    this.purpose,
    this.notes,
    this.remindersEnabled = false,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy;
  final String? purpose;
  final String? notes;
  final bool remindersEnabled;
  final bool isActive;

  Map<String, dynamic> toFirestore() {
    return {
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
      'isActive': isActive,
    };
  }

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medication(
      id: doc.id,
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
      isActive: data['isActive'] ?? true,
    );
  }

  Medication copyWith({
    String? id,
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
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      prescribedBy: prescribedBy ?? this.prescribedBy,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      isActive: isActive ?? this.isActive,
    );
  }
}
