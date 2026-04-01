import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Suppresses RenderFlex overflow errors and Firebase initialization
/// errors for the current test.
///
/// Must be called inside a `testWidgets` callback, not in `setUp`.
/// The test binding resets `FlutterError.onError` before each test,
/// so the override must be applied inside the test body.
///
/// Usage:
/// ```dart
/// testWidgets('my test', (tester) async {
///   suppressOverflowErrors();
///   // ... test code ...
/// });
/// ```
void suppressOverflowErrors() {
  final original = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final msg = details.toString();
    if (msg.contains('overflowed')) return;
    if (msg.contains('No Firebase App')) return;
    if (msg.contains('FirebaseException')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}
