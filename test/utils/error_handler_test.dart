import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/utils/error_handler.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppErrorHandler', () {
    group('singleton', () {
      test('instance is non-null', () {
        expect(AppErrorHandler.instance, isNotNull);
      });

      test('always returns the same instance', () {
        final a = AppErrorHandler.instance;
        final b = AppErrorHandler.instance;
        expect(identical(a, b), isTrue);
      });
    });

    group('init()', () {
      tearDown(() {
        // Reset navigator key after each test.
        AppErrorHandler.instance.init();
      });

      test('sets navigatorKey when provided', () {
        final key = GlobalKey<NavigatorState>();
        AppErrorHandler.instance.init(navigatorKey: key);
        expect(AppErrorHandler.instance.navigatorKey, same(key));
      });

      test('sets navigatorKey to null when called without argument', () {
        final key = GlobalKey<NavigatorState>();
        AppErrorHandler.instance.init(navigatorKey: key);
        AppErrorHandler.instance.init(); // reset
        expect(AppErrorHandler.instance.navigatorKey, isNull);
      });

      test('registers FlutterError.onError callback', () {
        AppErrorHandler.instance.init();
        expect(FlutterError.onError, isNotNull);
      });
    });

    group('reportError()', () {
      // When kEnableFirebase=true in the test environment, Firebase is not
      // initialised, so recordError() may throw a FirebaseException. We verify
      // that reportError() does not throw anything *other* than a Firebase
      // initialisation error — i.e. the non-Firebase code path runs correctly.
      void callReportError(Object error, [StackTrace? stack]) {
        try {
          if (stack != null) {
            AppErrorHandler.instance.reportError(error, stack);
          } else {
            AppErrorHandler.instance.reportError(error);
          }
        } catch (e) {
          // Only Firebase initialisation errors are expected; anything else
          // indicates a real bug in the handler.
          expect(e.toString(), contains('Firebase'),
              reason: 'Unexpected exception from reportError: $e');
        }
      }

      test('executes without unexpected exceptions for a simple error object', () {
        callReportError(Exception('test error'));
      });

      test('executes without unexpected exceptions when stack trace is provided', () {
        final stack = StackTrace.current;
        callReportError(Exception('test with stack'), stack);
      });

      test('executes without unexpected exceptions for a string error', () {
        callReportError('string error');
      });

      test('executes without unexpected exceptions for an Error subtype', () {
        callReportError(StateError('state error'));
      });
    });

    group('showUserError()', () {
      testWidgets('displays a SnackBar with the provided message',
          (tester) async {
        await tester.pumpWidget(testApp(Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                AppErrorHandler.instance.showUserError(
                  context,
                  'Something went wrong',
                );
              },
              child: const Text('trigger'),
            );
          },
        )));

        await tester.tap(find.text('trigger'));
        await tester.pump();

        expect(find.text('Something went wrong'), findsOneWidget);
      });

      testWidgets('shows a floating SnackBar', (tester) async {
        late BuildContext capturedCtx;
        await tester.pumpWidget(testApp(Builder(
          builder: (context) {
            capturedCtx = context;
            return const SizedBox();
          },
        )));
        await tester.pump();

        AppErrorHandler.instance.showUserError(capturedCtx, 'float test');
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.behavior, SnackBarBehavior.floating);
      });

      testWidgets('can be called multiple times without throwing',
          (tester) async {
        late BuildContext capturedCtx;
        await tester.pumpWidget(testApp(Builder(
          builder: (context) {
            capturedCtx = context;
            return const SizedBox();
          },
        )));
        await tester.pump();

        // First call — verify the snackbar appears.
        AppErrorHandler.instance.showUserError(capturedCtx, 'first error');
        await tester.pump();
        expect(find.text('first error'), findsOneWidget);

        // Second call while the first snackbar is still animating — should not throw.
        expect(
          () => AppErrorHandler.instance.showUserError(capturedCtx, 'second error'),
          returnsNormally,
        );
      });
    });

    group('showUserErrorGlobal()', () {
      setUp(() {
        // Ensure no navigator key is set before each test.
        AppErrorHandler.instance.init();
      });

      test('does not throw when no navigatorKey is set', () {
        expect(
          () => AppErrorHandler.instance
              .showUserErrorGlobal('global error without key'),
          returnsNormally,
        );
      });

      test('does not throw when navigatorKey has no current context', () {
        final key = GlobalKey<NavigatorState>();
        AppErrorHandler.instance.init(navigatorKey: key);

        // Key is set but has no mounted widget — currentContext is null.
        expect(
          () => AppErrorHandler.instance
              .showUserErrorGlobal('no context available'),
          returnsNormally,
        );
      });
    });
  });
}
