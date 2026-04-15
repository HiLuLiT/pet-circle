import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/services/abstract_push_notification_service.dart';
import 'package:pet_circle/services/reminder_service.dart';
import 'package:pet_circle/stores/notification_store.dart';

/// Top-level background handler — must be a top-level function for FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The OS displays the notification automatically from the FCM payload.
  // No additional work needed here for now.
}

/// Route prefixes that are safe to navigate to from push notification taps.
/// Prevents malicious FCM payloads from navigating to arbitrary routes.
const _allowedRoutePrefixes = ['/shell', '/invite'];

/// Manages Firebase Cloud Messaging lifecycle: token registration,
/// foreground message display, and notification-tap routing.
class PushNotificationService implements AbstractPushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _initialized = false;
  bool _tapHandlerWired = false;
  String? _currentToken;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<String>? _localTapSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  @override
  Future<void> init() async {
    if (_initialized) return;

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // iOS: show alerts/badges/sound while app is in the foreground.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // ── Token management ──────────────────────────────────────────────

  @override
  Future<void> registerToken(String uid) async {
    final permitted = await requestPermission();
    if (!permitted) {
      developer.log(
        'Push permission denied — skipping token registration',
        name: 'PushNotificationService',
      );
      return;
    }

    // Cancel any previous token-refresh listener to avoid stale uid closures.
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        await _persistToken(uid, token, isInitial: true);
      }

      // Listen for token refresh (e.g. app restore, OS token rotation).
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        _persistToken(uid, newToken, isInitial: false);
      });
    } catch (e) {
      developer.log(
        'FCM token registration failed: $e',
        name: 'PushNotificationService',
      );
    }
  }

  @override
  Future<void> unregisterToken(String uid) async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    try {
      if (_currentToken != null) {
        final docId = _tokenDocId(_currentToken!);
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('fcmTokens')
            .doc(docId)
            .delete();
      }
      await _messaging.deleteToken();
      _currentToken = null;
    } catch (e) {
      developer.log(
        'FCM token unregistration failed: $e',
        name: 'PushNotificationService',
      );
    }
  }

  Future<void> _persistToken(
    String uid,
    String token, {
    required bool isInitial,
  }) async {
    final docId = _tokenDocId(token);
    final platform = _currentPlatformString();
    final data = <String, dynamic>{
      'token': token,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isInitial) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  /// Generate a stable document ID from a token using its content hash.
  /// Uses a simple FNV-1a-like hash that is stable across Dart platforms
  /// (unlike String.hashCode which is not guaranteed stable).
  String _tokenDocId(String token) {
    var hash = 0x811c9dc5;
    for (var i = 0; i < token.length; i++) {
      hash ^= token.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  String _currentPlatformString() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.macOS:
        return 'macos';
      default:
        return 'unknown';
    }
  }

  // ── Foreground message handler ────────────────────────────────────

  @override
  void setupForegroundHandler() {
    _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? '';
    final body = notification.body ?? '';
    final data = message.data;

    // Display as a local heads-up notification.
    final notifId =
        (message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString())
                .hashCode &
            0x7FFFFFFF;
    await ReminderService.instance.showImmediateNotification(
      notifId,
      title,
      body,
      json.encode(data),
    );

    // Also add to the in-app notification list.
    final type = _notificationTypeFromData(data);
    final appNotification = AppNotification(
      id: message.messageId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      petName: data['petName'],
      route: data['route'],
      petId: data['petId'],
    );
    notificationStore.addLocal(appNotification);
  }

  NotificationType _notificationTypeFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
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

  // ── Notification tap routing ──────────────────────────────────────

  @override
  void setupNotificationTapHandler(void Function(String route) navigate) {
    // Guard against wiring tap handlers twice (e.g. hot restart).
    if (_tapHandlerWired) return;
    _tapHandlerWired = true;

    // App opened from background by tapping a FCM notification.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _routeFromMessage(navigate, message);
    });

    // Local notification taps (medication/measurement reminders).
    _localTapSub?.cancel();
    _localTapSub = ReminderService.onNotificationTap.stream.listen((route) {
      _safeNavigate(navigate, route);
    });

    // Defer initial-message and pending-route checks to after the widget tree
    // is mounted.  Calling router.go() before runApp would be silently ignored.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messaging.getInitialMessage().then((message) {
        if (message != null) {
          _routeFromMessage(navigate, message);
        }
      });

      // Check if the app was cold-launched by tapping a local notification.
      ReminderService.consumePendingRoute().then((pendingRoute) {
        if (pendingRoute != null && pendingRoute.isNotEmpty) {
          _safeNavigate(navigate, pendingRoute);
        }
      });
    });
  }

  void _routeFromMessage(
    void Function(String route) navigate,
    RemoteMessage message,
  ) {
    final route = message.data['route'] as String?;
    if (route != null) {
      _safeNavigate(navigate, route);
    }
  }

  /// Navigate only to whitelisted route prefixes to prevent malicious FCM
  /// payloads from triggering arbitrary navigation.
  void _safeNavigate(void Function(String route) navigate, String route) {
    if (route.isEmpty) return;
    final isAllowed =
        _allowedRoutePrefixes.any((prefix) => route.startsWith(prefix));
    if (!isAllowed) {
      developer.log(
        'Blocked navigation to disallowed route: $route',
        name: 'PushNotificationService',
      );
      return;
    }
    navigate(route);
  }
}
