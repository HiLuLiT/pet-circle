import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/settings/settings_content.dart';
import 'package:pet_circle/screens/settings/settings_widgets.dart';
import 'package:pet_circle/screens/settings/settings_care_circle_widgets.dart';
import 'package:pet_circle/widgets/app_toggle.dart';

import '../../helpers/helpers.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/test_http_overrides.dart';

/// Shared helper: sets a tall viewport so all sections render without overflow.
void _setTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(600, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  // ---------------------------------------------------------------------------
  // SettingsContent — rendering
  // ---------------------------------------------------------------------------
  group('SettingsContent rendering', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsContent), findsOneWidget);
    });

    testWidgets('shows header title and subtitle', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Manage your PetBreath preferences'), findsOneWidget);
    });

    testWidgets('shows close button when onClose callback provided', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      var closed = false;
      await tester.pumpWidget(testApp(
        SettingsContent(onClose: () => closed = true),
      ));
      await tester.pumpAndSettle();

      final closeIcon = find.byIcon(Icons.close);
      expect(closeIcon, findsOneWidget);
      await tester.tap(closeIcon);
      expect(closed, isTrue);
    });

    testWidgets('does not show close button when onClose is null', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('shows appearance section', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('shows care circle section', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Care Circle'), findsOneWidget);
    });

    testWidgets('shows notifications section with toggles', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('In-app notifications'), findsOneWidget);
      expect(find.text('Emergency alerts'), findsOneWidget);
    });

    testWidgets('shows measurement settings section', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Measurement settings'), findsOneWidget);
      // VisionRR camera mode is hidden behind kEnableVisionRR (not shipped yet).
      expect(find.text('VisionRR camera mode'), findsNothing);
    });

    testWidgets('shows data and privacy section', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Data & Privacy'), findsOneWidget);
      expect(find.text('Export All Data'), findsOneWidget);
    });

    testWidgets('shows about section', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('shows sign out button', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('renders multiple SettingsCard widgets', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      // Appearance, Care Circle, Notifications, Measurement, Data & Privacy, About
      expect(find.byType(SettingsCard), findsAtLeast(5));
    });

    testWidgets('renders multiple SettingsToggleRow widgets', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsToggleRow), findsAtLeast(4));
    });

    testWidgets('renders AppToggle for each toggle row', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.byType(AppToggle), findsAtLeast(4));
    });
  });

  // ---------------------------------------------------------------------------
  // SettingsContent — care circle members display
  // ---------------------------------------------------------------------------
  group('SettingsContent care circle members', () {
    testWidgets('shows care circle members from mock data', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      // The mock pet has care circle members — CareCircleItem widgets should appear
      expect(find.byType(CareCircleItem), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // SettingsContent — scrollability
  // ---------------------------------------------------------------------------
  group('SettingsContent scrollability', () {
    testWidgets('accepts a scroll controller', (tester) async {
      suppressOverflowErrors();
      _setTallView(tester);
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(testApp(
        SettingsContent(scrollController: controller),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsContent), findsOneWidget);
    });
  });
}
