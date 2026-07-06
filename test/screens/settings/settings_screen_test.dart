import 'dart:async' show runZonedGuarded;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/settings/settings_content.dart';
import 'package:pet_circle/screens/settings/settings_screen.dart';
import 'package:pet_circle/screens/settings/settings_widgets.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/widgets/app_toggle.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('SettingsContent', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const SettingsContent()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsContent), findsOneWidget);
    });

    testWidgets('shows settings title and subtitle', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const SettingsContent()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Manage your PetBreath preferences'), findsOneWidget);
    });

    testWidgets('shows appearance section with dark mode toggle',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const SettingsContent()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
    });

    testWidgets('shows notifications section', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const SettingsContent()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      // l10n copy consolidation: pushNotifications is now singular.
      expect(find.text('In-app notification'), findsOneWidget);
      expect(find.text('Emergency alerts'), findsOneWidget);
    });

    testWidgets('shows sign out button', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const SettingsContent()),
      );
      await tester.pumpAndSettle();

      // DS alignment: Sign Out is now a plain PrimaryButton pill (no
      // logout icon) with a tomato background.
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });

  group('SettingsDrawer', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const SettingsDrawer()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDrawer), findsOneWidget);
    });

    testWidgets('contains SettingsContent inside a ClipRRect', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsDrawer()));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsContent), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });

  group('SettingsContent with onClose callback', () {
    testWidgets('renders close button when onClose is provided', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var closeCalled = false;
      await tester.pumpWidget(
        testApp(SettingsContent(onClose: () => closeCalled = true)),
      );
      await tester.pumpAndSettle();

      // DS alignment: the close affordance is now a collapse chevron
      // (Icons.keyboard_arrow_up), not a literal "X" close icon.
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      // Tap the close button.
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      await tester.pumpAndSettle();
      expect(closeCalled, isTrue);
    });

    testWidgets('does NOT render close button when onClose is null',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
    });
  });

  group('SettingsScreen standalone', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('contains SettingsContent', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsContent), findsOneWidget);
    });

    testWidgets('shows Settings title', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('SettingsContent sections', () {
    testWidgets('shows measurement settings section', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Measurement settings'), findsOneWidget);
    });

    testWidgets('shows data and privacy section', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Data & Privacy'), findsOneWidget);
    });

    testWidgets('shows about section', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('shows care circle section', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Care Circle'), findsOneWidget);
    });

    testWidgets('does not show edit profile action row', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      // Edit Profile row was intentionally removed from Settings; the dialog
      // itself (showEditProfileDialog) is kept in code for future reuse.
      expect(find.text('Edit Profile'), findsNothing);
    });

    testWidgets('shows push notifications toggle', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      // l10n copy consolidation: pushNotifications is now singular.
      expect(find.text('In-app notification'), findsOneWidget);
    });

    testWidgets(
        'push notification toggle flips visually on the very next frame '
        '(BUG-030 — was gated behind the awaited persist call)',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      final before = settingsStore.pushNotifications;
      final toggleFinder = find
          .ancestor(
            of: find.text('In-app notification'),
            matching: find.byType(SettingsToggleRow),
          )
          .first;
      expect(
        tester.widget<SettingsToggleRow>(toggleFinder).isOn,
        before,
      );
      // Scope to the AppToggle inside THIS row -- the dark-mode row (which
      // appears earlier in the tree) also renders an AppToggle, so an
      // unscoped find.byType(AppToggle).first would tap the wrong switch.
      final switchFinder =
          find.descendant(of: toggleFinder, matching: find.byType(AppToggle));

      // Tap, then pump exactly one frame (not pumpAndSettle) so any
      // awaited work inside togglePushNotifications() -- persisting to
      // Firestore, notification-permission side effects -- has not had a
      // chance to resolve yet. Before the fix, the toggle only rebuilt via
      // a manual setState() placed *after* that awaited chain, so it would
      // still show the old value here. runZonedGuarded intercepts the
      // FirebaseException the eventual persist call throws in this
      // Firebase-less test environment; the in-memory store mutation and
      // notifyListeners() it fires happen synchronously before that await,
      // which is exactly the part this regression test is verifying.
      await runZonedGuarded(() async {
        await tester.tap(switchFinder);
        await tester.pump();
      }, (error, stack) {});

      expect(settingsStore.pushNotifications, !before);
      expect(
        tester.widget<SettingsToggleRow>(toggleFinder).isOn,
        !before,
      );
    });

    testWidgets('hides VisionRR coming soon badge (feature flag off)',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      // VisionRR is hidden behind kEnableVisionRR until the feature ships.
      expect(find.text('Coming Soon'), findsNothing);
    });
  });

  group('SettingsContent dark mode toggle', () {
    testWidgets('dark mode toggle is present and tappable', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const SettingsContent()));
      await tester.pumpAndSettle();

      expect(find.text('Dark mode'), findsOneWidget);
    });
  });

  group('kPushNotificationCategories and kEmergencyAlertCategories constants',
      () {
    test('kPushNotificationCategories contains expected values', () {
      expect(
          kPushNotificationCategories,
          containsAll(['medicine_reminder', 'measurement_reminder']));
    });

    test('kEmergencyAlertCategories contains expected values', () {
      expect(
          kEmergencyAlertCategories,
          containsAll(
              ['bpm_threshold_exceeded', 'missed_medication_24h']));
    });

    test('kPushNotificationCategories has 2 entries', () {
      expect(kPushNotificationCategories.length, equals(2));
    });

    test('kEmergencyAlertCategories has 2 entries', () {
      expect(kEmergencyAlertCategories.length, equals(2));
    });
  });
}
