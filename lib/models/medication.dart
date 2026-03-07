import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final bool isActive;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
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
      isActive: data['isActive'] ?? true,
    );
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
