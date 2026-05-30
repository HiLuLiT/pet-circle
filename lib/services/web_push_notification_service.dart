import 'package:pet_circle/services/abstract_push_notification_service.dart';

/// No-op push notification service for the web platform.
/// Firebase Cloud Messaging push is not supported on web in this app.
class WebPushNotificationService implements AbstractPushNotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> registerToken(String uid) async {}

  @override
  Future<void> unregisterToken(String uid) async {}

  @override
  void setupForegroundHandler() {}

  @override
  void setupNotificationTapHandler(void Function(String route) navigate) {}
}
