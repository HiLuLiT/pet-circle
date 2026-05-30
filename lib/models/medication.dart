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
    this.supplyStartDate,
    this.restockLeadDays,
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

  /// When the current batch (of [totalSupply] doses) started.
  final DateTime? supplyStartDate;

  /// Fire the restock reminder this many days before predicted run-out.
  final int? restockLeadDays;

  /// Doses consumed per day, derived from frequency. null => not trackable.
  int? get dosesPerDay => switch (frequency) {
        'Once daily' => 1,
        'Twice daily' => 2,
        _ => null,
      };

  bool get hasSupplyTracking =>
      totalSupply != null && supplyStartDate != null && dosesPerDay != null;

  int get _daysElapsed {
    final d = DateTime.now().difference(supplyStartDate!).inDays;
    return d < 0 ? 0 : d;
  }

  /// Remaining doses, clamped to [0, totalSupply].
  int get remainingDoses {
    if (!hasSupplyTracking) return 0;
    final used = dosesPerDay! * _daysElapsed;
    return (totalSupply! - used).clamp(0, totalSupply!).toInt();
  }

  /// Predicted date the batch runs out.
  DateTime get runOutDate => supplyStartDate!
      .add(Duration(days: (totalSupply! / dosesPerDay!).ceil()));

  /// When the restock reminder should fire.
  DateTime get restockDate =>
      runOutDate.subtract(Duration(days: restockLeadDays ?? 5));

  /// True once within the restock lead window.
  bool get needsRestock =>
      hasSupplyTracking && !DateTime.now().isBefore(restockDate);

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
      if (supplyStartDate != null)
        'supplyStartDate': Timestamp.fromDate(supplyStartDate!),
      if (restockLeadDays != null) 'restockLeadDays': restockLeadDays,
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
      supplyStartDate: data['supplyStartDate'] != null
          ? (data['supplyStartDate'] as Timestamp).toDate()
          : (data['totalSupply'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : null),
      restockLeadDays: data['restockLeadDays'] as int?,
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
    DateTime? supplyStartDate,
    bool clearSupplyStartDate = false,
    int? restockLeadDays,
    bool clearRestockLeadDays = false,
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
      supplyStartDate: clearSupplyStartDate
          ? null
          : (supplyStartDate ?? this.supplyStartDate),
      restockLeadDays: clearRestockLeadDays
          ? null
          : (restockLeadDays ?? this.restockLeadDays),
    );
  }
}
