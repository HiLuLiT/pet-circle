import 'package:cloud_firestore/cloud_firestore.dart';

class Measurement {
  const Measurement({
    this.id,
    required this.bpm,
    required this.recordedAt,
    this.recordedAtLabel,
    this.recordedBy,
  });

  final String? id;
  final int bpm;
  final DateTime recordedAt;
  final String? recordedAtLabel;
  final String? recordedBy;

  @Deprecated('Use formatTimeAgo(measurement.recordedAt) from utils/formatters.dart')
  String get timeAgo {
    if (recordedAtLabel != null) return recordedAtLabel!;
    final now = DateTime.now();
    final diff = now.difference(recordedAt);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min ago';
    }
    return 'Just now';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bpm': bpm,
      'recordedAt': Timestamp.fromDate(recordedAt),
      'recordedBy': recordedBy,
    };
  }

  factory Measurement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Measurement(
      id: doc.id,
      bpm: data['bpm'] ?? 0,
      recordedAt: _parseDateTime(data['recordedAt']),
      recordedBy: data['recordedBy'],
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Measurement copyWith({
    String? id,
    int? bpm,
    DateTime? recordedAt,
    String? recordedAtLabel,
    String? recordedBy,
  }) {
    return Measurement(
      id: id ?? this.id,
      bpm: bpm ?? this.bpm,
      recordedAt: recordedAt ?? this.recordedAt,
      recordedAtLabel: recordedAtLabel ?? this.recordedAtLabel,
      recordedBy: recordedBy ?? this.recordedBy,
    );
  }
}
