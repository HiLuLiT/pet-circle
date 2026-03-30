import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/services/notification_service.dart';
import 'package:pet_circle/stores/user_store.dart';

final notificationStore = NotificationStore();

class NotificationStore extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  StreamSubscription<List<AppNotification>>? _subscription;

  void seed(List<AppNotification> initial) {
    _notifications = List.of(initial);
    notifyListeners();
  }

  void reset() {
    _notifications = [];
    notifyListeners();
  }

  void subscribeForUser(String uid) {
    _subscription?.cancel();
    _subscription = NotificationService.streamNotifications(uid).listen((items) {
      _notifications = items;
      notifyListeners();
    });
  }

  void cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
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
