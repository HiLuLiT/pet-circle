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
    this.totalSupply,
    this.currentSupply,
    this.lowSupplyThreshold,
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

  /// Total number of doses dispensed (null = supply tracking disabled).
  final int? totalSupply;

  /// Remaining doses (null = supply tracking disabled).
  final int? currentSupply;

  /// Alert when currentSupply falls to this level (default: 7 when enabled).
  final int? lowSupplyThreshold;

  /// Whether supply tracking is active for this medication.
  bool get hasSupplyTracking => totalSupply != null && currentSupply != null;

  /// Whether the supply is running low.
  bool get isLowSupply =>
      hasSupplyTracking &&
      currentSupply! <= (lowSupplyThreshold ?? 7);

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
      if (totalSupply != null) 'totalSupply': totalSupply,
      if (currentSupply != null) 'currentSupply': currentSupply,
      if (lowSupplyThreshold != null) 'lowSupplyThreshold': lowSupplyThreshold,
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
      totalSupply: data['totalSupply'] as int?,
      currentSupply: data['currentSupply'] as int?,
      lowSupplyThreshold: data['lowSupplyThreshold'] as int?,
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
    int? totalSupply,
    bool clearTotalSupply = false,
    int? currentSupply,
    bool clearCurrentSupply = false,
    int? lowSupplyThreshold,
    bool clearLowSupplyThreshold = false,
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
      totalSupply:
          clearTotalSupply ? null : (totalSupply ?? this.totalSupply),
      currentSupply:
          clearCurrentSupply ? null : (currentSupply ?? this.currentSupply),
      lowSupplyThreshold: clearLowSupplyThreshold
          ? null
          : (lowSupplyThreshold ?? this.lowSupplyThreshold),
    );
  }
}
