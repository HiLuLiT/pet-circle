/// Platform-agnostic interface for push notification management.
///
/// Concrete implementations handle FCM token lifecycle, foreground message
/// display, and notification-tap routing.  The web stub is a no-op.
abstract class AbstractPushNotificationService {
  /// Initialise the underlying push messaging SDK.
  Future<void> init();

  /// Request OS-level notification permission (iOS/Android).
  Future<bool> requestPermission();

  /// Obtain the current FCM token and persist it to Firestore.
  Future<void> registerToken(String uid);

  /// Remove the persisted FCM token from Firestore and delete it locally.
  Future<void> unregisterToken(String uid);

  /// Begin listening for messages while the app is in the foreground.
  void setupForegroundHandler();

  /// Wire notification-tap callbacks so tapping a push opens the right route.
  /// [navigate] is a callback that performs the actual route change (e.g.
  /// `router.go`), keeping the service layer router-agnostic.
  void setupNotificationTapHandler(void Function(String route) navigate);
}
