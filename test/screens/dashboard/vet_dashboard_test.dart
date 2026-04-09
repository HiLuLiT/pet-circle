import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/user.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_http_overrides.dart';

/// Vet user with empty email to prevent Firebase invitation lookup
/// during initState (kEnableFirebase is const true).
final _testVetUser = User(
  id: 'vet-test',
  name: 'Dr. Test',
  email: '',
  role: UserRole.vet,
  avatarUrl: '',
);

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(() {
    seedAllStores();
    // Override with vet user whose empty email skips the Firebase call.
    userStore.seed(_testVetUser);
  });
  tearDown(resetAllStores);

  group('VetDashboard', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const VetDashboard(showScaffold: false)),
      );
      await tester.pump();

      expect(find.byType(VetDashboard), findsOneWidget);
    });

    testWidgets('shows clinic overview heading', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const VetDashboard(showScaffold: false)),
      );
      await tester.pump();

      expect(find.text('Clinic Overview'), findsOneWidget);
    });

    testWidgets('shows patient count text', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const VetDashboard(showScaffold: false)),
      );
      await tester.pump();

      final petCount = petStore.allClinicPets.length;
      expect(
        find.textContaining('$petCount'),
        findsWidgets,
        reason: 'Should display patient count somewhere',
      );
    });

    testWidgets('shows pet names from clinic data', (tester) async {
      suppressOverflowErrors();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const VetDashboard(showScaffold: false)),
      );
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

      await tester.pumpWidget(
        testApp(const VetDashboard(showScaffold: false)),
      );
      await tester.pump();

      expect(find.text('Normal Status'), findsWidgets);
      expect(find.text('Need Attention'), findsWidgets);
    });
  });
}
