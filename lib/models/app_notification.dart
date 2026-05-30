import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  measurement,
  medication,
  careCircle,
  report,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.petName,
    this.route,
    this.petId,
    this.titleKey,
    this.bodyKey,
    this.args = const [],
  });

  final String id;

  /// Resolved title text, frozen at creation time. Used as a fallback when
  /// [titleKey] is null (e.g. server-pushed or legacy notifications).
  final String title;

  /// Resolved body text, frozen at creation time. Fallback for [bodyKey].
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? petName;
  final String? route;
  final String? petId;

  /// Localization key for the title (e.g. `medicationAdded`). When set, the UI
  /// re-localizes the title at render time so it follows the current language.
  final String? titleKey;

  /// Localization key for the body (e.g. `measurementSavedBpm`).
  final String? bodyKey;

  /// Positional arguments for a templated [bodyKey], stored as strings.
  final List<String> args;

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'petName': petName,
      if (route != null) 'route': route,
      if (petId != null) 'petId': petId,
      if (titleKey != null) 'titleKey': titleKey,
      if (bodyKey != null) 'bodyKey': bodyKey,
      if (args.isNotEmpty) 'args': args,
    };
  }

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: _typeFromString(data['type']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      petName: data['petName'],
      route: data['route'],
      petId: data['petId'],
      titleKey: data['titleKey'],
      bodyKey: data['bodyKey'],
      args: (data['args'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? petName,
    String? route,
    String? petId,
    String? titleKey,
    String? bodyKey,
    List<String>? args,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      petName: petName ?? this.petName,
      route: route ?? this.route,
      petId: petId ?? this.petId,
      titleKey: titleKey ?? this.titleKey,
      bodyKey: bodyKey ?? this.bodyKey,
      args: args ?? this.args,
    );
  }

  @Deprecated('Use formatTimeAgoShort(notification.createdAt) from utils/formatters.dart')
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}

NotificationType _typeFromString(Object? value) {
  switch (value) {
    case 'medication':
      return NotificationType.medication;
    case 'careCircle':
      return NotificationType.careCircle;
    case 'report':
      return NotificationType.report;
    case 'measurement':
    default:
      return NotificationType.measurement;
  }
}
