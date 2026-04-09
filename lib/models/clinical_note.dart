import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicalNote {
  const ClinicalNote({
    required this.id,
    this.authorUid,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String? authorUid;
  final String authorName;
  final String authorAvatarUrl;
  final String content;
  final DateTime createdAt;

  @Deprecated('Use formatTimeAgo(note.createdAt) from utils/formatters.dart')
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
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
      'authorUid': authorUid,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ClinicalNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClinicalNote(
      id: doc.id,
      authorUid: data['authorUid'],
      authorName: data['authorName'] ?? '',
      authorAvatarUrl: data['authorAvatarUrl'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
