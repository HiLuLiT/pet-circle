import 'package:flutter/foundation.dart';

/// Centralises platform capability detection, replacing scattered
/// `kIsWeb` / `Platform.is*` checks across the codebase.
class PlatformCapabilities {
  // Private constructor — this class is purely static.
  PlatformCapabilities._();

  /// True on iOS, Android, and macOS where flutter_local_notifications
  /// is supported.
  static bool get supportsNotifications =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// True on any native platform where share_plus / file I/O is available.
  static bool get supportsFileShare => !kIsWeb;

  /// True on iOS and macOS where Sign in with Apple is available.
  static bool get supportsAppleSignIn =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// True on macOS, Linux, and Windows.
  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows);

  /// True on iOS and Android.
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// True when running as a web app.
  static bool get isWeb => kIsWeb;
}
