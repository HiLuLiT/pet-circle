// `flutter_local_notifications` re-exports only the value types from its
// platform interface, not `FlutterLocalNotificationsPlatform` itself, so the
// class this fake extends has to be imported from the transitive package.
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

/// A no-op [FlutterLocalNotificationsPlatform] for widget tests.
///
/// The real platform implementation only registers itself on a device, so any
/// code path that reaches `FlutterLocalNotificationsPlugin` under
/// `flutter_test` throws a `LateInitializationError`. Installing this fake
/// makes those fire-and-forget scheduling/cancelling calls harmless.
class FakeLocalNotificationsPlatform extends FlutterLocalNotificationsPlatform {
  final List<int> cancelledIds = <int>[];
  bool cancelledAll = false;

  @override
  Future<void> cancel(int id) async => cancelledIds.add(id);

  @override
  Future<void> cancelAll() async => cancelledAll = true;

  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    String? payload,
  }) async {}

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async
  => null;

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async
  => const [];

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => const [];
}

/// Installs a fresh [FakeLocalNotificationsPlatform] and returns it.
FakeLocalNotificationsPlatform installFakeLocalNotifications() {
  final fake = FakeLocalNotificationsPlatform();
  FlutterLocalNotificationsPlatform.instance = fake;
  return fake;
}
