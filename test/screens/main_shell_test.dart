import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/user.dart';
import 'package:pet_circle/screens/main_shell.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/widgets/bottom_nav_bar.dart';
import '../helpers/ignore_overflow_errors.dart';
import '../helpers/mock_stores.dart';
import '../helpers/test_app.dart';
import '../helpers/test_http_overrides.dart';

/// Vet user with empty email to prevent Firebase invitation lookup
/// in VetDashboard.initState (kEnableFirebase is const true).
const _testVetUser = User(
  id: 'vet-test',
  name: 'Dr. Test',
  email: '',
  role: UserRole.vet,
  avatarUrl: '',
);

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('MainShell', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const MainShell()),
      );
      await tester.pump();

      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('shows bottom navigation bar', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const MainShell()),
      );
      await tester.pump();

      expect(find.byType(BottomNavBar), findsOneWidget);
    });

    testWidgets('bottom nav bar has 5 tab labels', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const MainShell()),
      );
      await tester.pump();

      // Tab labels appear in the BottomNavBar. Some labels may also
      // appear in the tab content (e.g. "Trends" heading), so use
      // findsWidgets to allow duplicates.
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Trends'), findsWidgets);
      expect(find.text('Circle'), findsWidgets);
      expect(find.text('Mesure'), findsWidgets);
      expect(find.text('Medicine'), findsWidgets);
    });

    testWidgets('renders with vet role', (tester) async {
      suppressOverflowErrors();
      // Use vet user with empty email to skip Firebase invitation lookup.
      userStore.seed(_testVetUser);

      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const MainShell()),
      );
      await tester.pump();

      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(BottomNavBar), findsOneWidget);
    });

    testWidgets('respects initialIndex parameter', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const MainShell(initialIndex: 2)),
      );
      await tester.pump();

      expect(find.byType(BottomNavBar), findsOneWidget);
    });
  });

  group('MainShell — navigation', () {
    testWidgets('starts on index 0 by default', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MainShell()));
      await tester.pump();

      final navBar = tester.widget<BottomNavBar>(find.byType(BottomNavBar));
      expect(navBar.selectedIndex, 0);
    });

    testWidgets('starts on correct index when initialIndex is set', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MainShell(initialIndex: 3)));
      await tester.pump();

      final navBar = tester.widget<BottomNavBar>(find.byType(BottomNavBar));
      expect(navBar.selectedIndex, 3);
    });

    testWidgets('uses wide layout on tablet screen (>=768px)', (tester) async {
      suppressOverflowErrors();
      // Tablet width triggers NavigationRail layout.
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MainShell()));
      await tester.pump();

      // Wide layout uses NavigationRail instead of BottomNavBar.
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(BottomNavBar), findsNothing);
    });

    testWidgets('NavigationRail has 5 destinations on wide layout', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MainShell()));
      await tester.pump();

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.destinations.length, 5);
    });

    testWidgets('uses narrow layout on phone screen (<768px)', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MainShell()));
      await tester.pump();

      expect(find.byType(BottomNavBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('IndexedStack renders correct number of children', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MainShell()));
      await tester.pump();

      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.children.length, 5);
    });
  });
}
