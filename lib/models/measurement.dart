class Measurement {
  const Measurement({
    required this.bpm,
    required this.recordedAt,
    this.recordedAtLabel,
  });

  final int bpm;
  final DateTime recordedAt;
  final String? recordedAtLabel;

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

  Measurement copyWith({
    int? bpm,
    DateTime? recordedAt,
    String? recordedAtLabel,
  }) {
    return Measurement(
      bpm: bpm ?? this.bpm,
      recordedAt: recordedAt ?? this.recordedAt,
      recordedAtLabel: recordedAtLabel ?? this.recordedAtLabel,
    );
  }
}
