import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;

/// Centralized error handler for unhandled Flutter and platform errors.
///
/// Initialise once at startup via [AppErrorHandler.instance.init].
/// Use [reportError] to surface caught errors from business logic.
/// Use [showUserError] to display a recoverable error in the UI.
class AppErrorHandler {
  AppErrorHandler._();

  static final AppErrorHandler instance = AppErrorHandler._();

  GlobalKey<NavigatorState>? navigatorKey;

  /// Wire up Flutter and platform error callbacks.
  ///
  /// Call this as the first statement in [main], before [runApp].
  void init({GlobalKey<NavigatorState>? navigatorKey}) {
    this.navigatorKey = navigatorKey;
    FlutterError.onError = _handleFlutterError;
    PlatformDispatcher.instance.onError = _handlePlatformError;
  }

  // ---------------------------------------------------------------------------
  // Framework callbacks
  // ---------------------------------------------------------------------------

  void _handleFlutterError(FlutterErrorDetails details) {
    // Retain default presentation (red screen in debug, grey box in release).
    FlutterError.presentError(details);
    debugPrint('[AppErrorHandler] FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint('[AppErrorHandler] Stack:\n${details.stack}');
    }
    if (kEnableFirebase) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  }

  bool _handlePlatformError(Object error, StackTrace stack) {
    debugPrint('[AppErrorHandler] PlatformError: $error\n$stack');
    if (kEnableFirebase) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true; // Mark as handled so the OS does not terminate the app.
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Report a caught error from business / store logic.
  ///
  /// Logs locally and forwards to Crashlytics when Firebase is enabled.
  void reportError(Object error, [StackTrace? stack]) {
    debugPrint('[AppErrorHandler] reportError: $error');
    if (stack != null) debugPrint('[AppErrorHandler] Stack:\n$stack');
    if (kEnableFirebase) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
  }

  /// Show a user-friendly [SnackBar] for a recoverable error.
  ///
  /// Requires a valid [BuildContext] with a [ScaffoldMessenger] ancestor.
  void showUserError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a user-friendly [SnackBar] using the root navigator's context.
  ///
  /// Useful from stores or services that lack a [BuildContext].
  /// Only works after a [navigatorKey] has been provided to [init].
  void showUserErrorGlobal(String message) {
    final context = navigatorKey?.currentContext;
    if (context == null) {
      debugPrint(
        '[AppErrorHandler] showUserErrorGlobal: no context available — message: $message',
      );
      return;
    }
    showUserError(context, message);
  }
}
