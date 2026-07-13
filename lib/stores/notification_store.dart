import 'package:flutter/foundation.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/notification_service.dart';
import 'package:pet_circle/stores/user_store.dart';

final notificationStore = NotificationStore();

class NotificationStore extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  String? _subscribedUid;

  void seed(List<AppNotification> initial) {
    _notifications = List.of(initial);
    notifyListeners();
  }

  void reset() {
    _notifications = [];
    _subscribedUid = null;
    notifyListeners();
  }

  /// Fetch notifications for a user from Firestore (one-time read).
  Future<void> fetchForUser(String uid) async {
    _subscribedUid = uid;
    _notifications = await NotificationService.fetchNotifications(uid);
    notifyListeners();
  }

  /// Re-fetch notifications (pull-to-refresh).
  Future<void> refresh() async {
    if (_subscribedUid == null) return;
    await fetchForUser(_subscribedUid!);
  }

  void clearData() {
    _subscribedUid = null;
    _notifications = [];
  }

  List<AppNotification> get all => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<AppNotification> get unread =>
      List.unmodifiable(_notifications.where((n) => !n.isRead).toList());

  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    notifyListeners();

    final uid = userStore.currentUserUid;
    if (kEnableFirebase && uid != null && uid.isNotEmpty) {
      await NotificationService.addNotification(uid, notification);
    }
  }

  /// Add a notification to the in-memory list only (no Firestore write).
  /// Used for FCM foreground messages where the server already persisted it.
  void addLocal(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Add an in-app notification for each medication whose end date has arrived,
  /// once per medication end date. Persists to Firestore so markRead sticks.
  ///
  /// Dedup key is `med-end-<medId>-<endDayEpoch>`, so a given medication's end
  /// date only ever produces a single in-app entry.
  Future<void> reconcileMedicationEndNotifications(
    List<Medication> endedMeds, {
    required String title,
    required String body,
    String? petName,
  }) async {
    final uid = kEnableFirebase ? userStore.currentUserUid : null;
    for (final med in endedMeds) {
      final endDate = med.endDate;
      if (endDate == null) continue;
      final dayEpoch = endDate.millisecondsSinceEpoch ~/ 86400000;
      final id = 'med-end-${med.id}-$dayEpoch';
      if (_notifications.any((n) => n.id == id)) continue;
      final effectivePetName = petName ?? med.name;
      final notif = AppNotification(
        id: id,
        title: title,
        body: body,
        titleKey: 'medicationEndingTitle',
        bodyKey: 'medicationEndingBody',
        args: [effectivePetName, med.name],
        type: NotificationType.medication,
        createdAt: DateTime.now(),
        petName: effectivePetName,
        petId: med.petId,
      );
      _notifications.insert(0, notif);
      notifyListeners();
      if (uid != null && uid.isNotEmpty) {
        try {
          await NotificationService.addNotification(uid, notif);
        } catch (e) {
          debugPrint('[NotificationStore] Failed to persist med-end notification: $e');
        }
      }
    }
  }

  Future<void> markRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }

    final uid = userStore.currentUserUid;
    if (kEnableFirebase && uid != null && uid.isNotEmpty) {
      try {
        await NotificationService.markRead(uid, id);
      } catch (e) {
        if (idx != -1) {
          _notifications[idx] = _notifications[idx].copyWith(isRead: false);
          notifyListeners();
        }
        rethrow;
      }
    }
  }

  Future<void> markAllRead() async {
    final previous = List<AppNotification>.of(_notifications);
    _notifications = _notifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();
    notifyListeners();

    final uid = userStore.currentUserUid;
    if (kEnableFirebase && uid != null && uid.isNotEmpty) {
      try {
        await NotificationService.markAllRead(uid);
      } catch (e) {
        _notifications = previous;
        notifyListeners();
        rethrow;
      }
    }
  }
}
