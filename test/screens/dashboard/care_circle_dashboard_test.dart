import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/dashboard/care_circle_dashboard.dart';
import 'package:pet_circle/stores/pet_store.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_http_overrides.dart';

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('CareCircleDashboard', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const CareCircleDashboard()));
      await tester.pump();

      expect(find.byType(CareCircleDashboard), findsOneWidget);
    });

    testWidgets('shows pet cards from clinic data', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const CareCircleDashboard()));
      await tester.pump();

      final pets = petStore.allClinicPets;
      if (pets.isNotEmpty) {
        expect(find.text(pets.first.name), findsOneWidget);
      }
    });

    testWidgets('shows summary cards with status labels', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const CareCircleDashboard()));
      await tester.pump();

      expect(find.text('Normal Status'), findsWidgets);
      expect(find.text('Need Attention'), findsWidgets);
    });

    testWidgets('shows Care Circle label on pet cards', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const CareCircleDashboard()));
      await tester.pump();

      final pets = petStore.allClinicPets;
      if (pets.isNotEmpty) {
        expect(find.text('Care Circle'), findsWidgets);
      }
    });

    testWidgets('shows BPM label on pet cards', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const CareCircleDashboard()));
      await tester.pump();

      final pets = petStore.allClinicPets;
      if (pets.isNotEmpty) {
        expect(find.text('BPM'), findsWidgets);
      }
    });
  });
}
