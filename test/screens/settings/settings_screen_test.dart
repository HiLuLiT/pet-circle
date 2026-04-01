import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/screens/settings/settings_content.dart';
import 'package:pet_circle/screens/settings/settings_screen.dart';

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
        testApp(const SettingsContent(role: AppUserRole.owner)),
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
        testApp(const SettingsContent(role: AppUserRole.owner)),
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
        testApp(const SettingsContent(role: AppUserRole.owner)),
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
        testApp(const SettingsContent(role: AppUserRole.owner)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('In-app notifications'), findsOneWidget);
      expect(find.text('Emergency alerts'), findsOneWidget);
    });

    testWidgets('shows sign out button', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const SettingsContent(role: AppUserRole.owner)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });

  group('SettingsDrawer', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const SettingsDrawer(role: AppUserRole.owner)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDrawer), findsOneWidget);
    });
  });
}
