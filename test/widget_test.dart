import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/welcome_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

import 'helpers/ignore_overflow_errors.dart';
import 'helpers/test_http_overrides.dart';

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  testWidgets('WelcomeScreen renders without error', (WidgetTester tester) async {
    suppressOverflowErrors();

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const WelcomeScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    // Verify the "Create an account" heading is present on WelcomeScreen
    expect(find.text('Create an account'), findsOneWidget);
  });
}
