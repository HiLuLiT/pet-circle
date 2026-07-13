import 'package:cloud_firestore/cloud_firestore.dart';

/// An upcoming care reminder for a pet (e.g. a vet visit, grooming
/// appointment, or other scheduled task). Stored per-pet in
/// `/pets/{petId}/reminders`.
class Reminder {
  const Reminder({
    required this.id,
    required this.petId,
    required this.date,
    required this.title,
    this.detail,
    this.createdAt,
  });

  final String id;
  final String petId;
  final DateTime date;
  final String title;
  final String? detail;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'date': Timestamp.fromDate(date),
      'title': title,
      if (detail != null && detail!.isNotEmpty) 'detail': detail,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      petId: data['petId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      title: data['title'] ?? '',
      detail: data['detail'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Reminder copyWith({
    String? id,
    String? petId,
    DateTime? date,
    String? title,
    String? detail,
    bool clearDetail = false,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      date: date ?? this.date,
      title: title ?? this.title,
      detail: clearDetail ? null : (detail ?? this.detail),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
