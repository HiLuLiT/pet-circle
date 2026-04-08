import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/auth/verify_otp_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_http_overrides.dart';

/// Wraps [VerifyOtpScreen] in a GoRouter-based MaterialApp so that
/// context.canPop() / context.go() calls do not throw.
Widget _verifyOtpApp({
  required String email,
  bool isSignup = false,
  String? name,
}) {
  final router = GoRouter(
    initialLocation: '/verify-otp',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (_, _) => VerifyOtpScreen(
          email: email,
          isSignup: isSignup,
          name: name,
        ),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    theme: buildAppTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('VerifyOtpScreen', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        _verifyOtpApp(email: 'test@example.com'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VerifyOtpScreen), findsOneWidget);
    });

    testWidgets('shows "Check your email" heading', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        _verifyOtpApp(email: 'test@example.com'),
      );
      await tester.pumpAndSettle();

      // l10n enterVerificationCode => "Check your email"
      expect(find.text('Check your email'), findsOneWidget);
    });

    testWidgets('shows the email address', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        _verifyOtpApp(email: 'user@domain.com'),
      );
      await tester.pumpAndSettle();

      expect(find.text('user@domain.com'), findsOneWidget);
    });

    testWidgets('shows 6 digit input fields', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        _verifyOtpApp(email: 'test@example.com'),
      );
      await tester.pumpAndSettle();

      // 6 TextFormField widgets for the OTP digits
      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('shows "Verify" button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        _verifyOtpApp(email: 'test@example.com'),
      );
      await tester.pumpAndSettle();

      // l10n verifyCode => "Verify"
      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('shows "Resend code" text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        _verifyOtpApp(email: 'test@example.com'),
      );
      await tester.pumpAndSettle();

      // Initially the cooldown is active, so it shows "Resend code in 60s"
      // (or similar). Find a text that contains "Resend code".
      expect(find.textContaining('Resend code'), findsOneWidget);
    });

    testWidgets('shows "Use a different email" link', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        _verifyOtpApp(email: 'test@example.com'),
      );
      await tester.pumpAndSettle();

      // l10n useDifferentEmail => "Use a different email"
      expect(find.text('Use a different email'), findsOneWidget);
    });
  });
}
