import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/settings/settings_care_circle_widgets.dart';

import '../../helpers/helpers.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/test_http_overrides.dart';

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  // ---------------------------------------------------------------------------
  // InviteButton
  // ---------------------------------------------------------------------------
  group('InviteButton', () {
    testWidgets('renders invite label', (tester) async {
      suppressOverflowErrors();
      await tester.pumpWidget(testApp(
        InviteButton(onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Invite'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      suppressOverflowErrors();
      var tapped = false;
      await tester.pumpWidget(testApp(
        InviteButton(onTap: () => tapped = true),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // CareCircleItem
  // ---------------------------------------------------------------------------
  group('CareCircleItem', () {
    testWidgets('renders email, role label, and status label', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(
        CareCircleItem(
          email: 'owner@example.com',
          roleLabel: 'Admin',
          roleColor: Colors.purple,
          statusLabel: 'Active',
          statusColor: Colors.green,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('owner@example.com'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('calls onRemove when trash icon tapped', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var removeCalled = false;
      await tester.pumpWidget(testApp(
        CareCircleItem(
          email: 'member@example.com',
          roleLabel: 'Member',
          roleColor: Colors.blue,
          statusLabel: 'Active',
          statusColor: Colors.green,
          onRemove: () => removeCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap the GestureDetector wrapping the trash icon (last one in tree)
      await tester.tap(find.byType(GestureDetector).last);
      expect(removeCalled, isTrue);
    });

    testWidgets('renders without onRemove callback', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(
        const CareCircleItem(
          email: 'viewer@example.com',
          roleLabel: 'Viewer',
          roleColor: Colors.grey,
          statusLabel: 'Active',
          statusColor: Colors.green,
          onRemove: null,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('viewer@example.com'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ConfigureRow
  // ---------------------------------------------------------------------------
  group('ConfigureRow', () {
    testWidgets('renders alert thresholds label and configure button', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(
        ConfigureRow(onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alert thresholds'), findsOneWidget);
      expect(find.text('Configure'), findsOneWidget);
    });

    testWidgets('renders BPM customization description', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(
        ConfigureRow(onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Customize BPM ranges for alerts'), findsOneWidget);
    });

    testWidgets('calls onTap when configure button tapped', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var tapped = false;
      await tester.pumpWidget(testApp(
        ConfigureRow(onTap: () => tapped = true),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Configure'));
      expect(tapped, isTrue);
    });
  });
}
