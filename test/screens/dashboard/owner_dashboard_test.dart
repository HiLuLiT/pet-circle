import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/dashboard/owner_dashboard.dart';
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

  group('OwnerDashboard', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const OwnerDashboard(showScaffold: false)),
      );
      await tester.pump();

      expect(find.byType(OwnerDashboard), findsOneWidget);
    });

    testWidgets('shows My pets heading', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const OwnerDashboard(showScaffold: false)),
      );
      await tester.pump();

      expect(find.text('My pets'), findsOneWidget);
    });

    testWidgets('shows pet names from mock data', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const OwnerDashboard(showScaffold: false)),
      );
      await tester.pump();

      final pets = petStore.ownerPets;
      expect(pets, isNotEmpty, reason: 'Mock data should seed owner pets');
      expect(find.text(pets.first.name), findsOneWidget);
    });

    testWidgets('shows Add Pet button', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const OwnerDashboard(showScaffold: false)),
      );
      await tester.pump();

      expect(find.text('Add Pet'), findsOneWidget);
    });

    testWidgets('shows empty state when no pets', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      petStore.seed(ownerPets: [], clinicPets: []);

      await tester.pumpWidget(
        testApp(const OwnerDashboard(showScaffold: false)),
      );
      await tester.pump();

      expect(find.text('No pets yet'), findsOneWidget);
      expect(
        find.text('Add your first pet to get started with health monitoring.'),
        findsOneWidget,
      );
    });
  });
}
