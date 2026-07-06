import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/screens/dashboard/add_reminder_sheet.dart';
import 'package:pet_circle/screens/dashboard/owner_dashboard.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/reminder_store.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_http_overrides.dart';

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  Future<void> pumpDashboard(WidgetTester tester) async {
    suppressOverflowErrors();
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(const OwnerDashboard(showScaffold: false)),
    );
    await tester.pump();
  }

  group('OwnerDashboard', () {
    testWidgets('renders without error', (tester) async {
      await pumpDashboard(tester);
      expect(find.byType(OwnerDashboard), findsOneWidget);
    });

    testWidgets('shows Your pets heading', (tester) async {
      await pumpDashboard(tester);
      expect(find.text('Your pets'), findsOneWidget);
    });

    testWidgets('shows Add Pet button', (tester) async {
      await pumpDashboard(tester);
      expect(find.text('Add Pet'), findsOneWidget);
    });

    testWidgets('shows the active pet name in the hero card', (tester) async {
      await pumpDashboard(tester);

      final pet = petStore.activePet;
      expect(pet, isNotNull, reason: 'Mock data should seed an active pet');
      // The active pet's name also appears in the header (main_shell) and in
      // each reminder's pet-name chip when embedded in the full shell; in
      // isolation (showScaffold: false, no header) it should still appear at
      // least once via the hero card.
      expect(find.text(pet!.name), findsWidgets);
    });

    testWidgets('shows the Active status badge on the hero card',
        (tester) async {
      await pumpDashboard(tester);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows latest reading card with bpm and label', (tester) async {
      await pumpDashboard(tester);

      final pet = petStore.activePet!;
      final latest = measurementStore.latestForPet(pet.id ?? '');
      expect(latest, isNotNull);
      expect(find.text('${latest!.bpm} BPM'), findsOneWidget);
      expect(find.text('Latest Reading'), findsOneWidget);
    });

    testWidgets('hides latest reading card when there is no measurement',
        (tester) async {
      final pet = petStore.activePet!;
      measurementStore.seed({pet.id ?? '': const <Measurement>[]});

      await pumpDashboard(tester);

      expect(find.text('Latest Reading'), findsNothing);
    });

    testWidgets('shows Care Circle card with avatar stack', (tester) async {
      await pumpDashboard(tester);
      expect(find.text('Care Circle'), findsOneWidget);
    });

    testWidgets('shows Reminders card with seeded reminder titles',
        (tester) async {
      await pumpDashboard(tester);

      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Veterinary dentist'), findsOneWidget);
      expect(find.text('Vaccination booster'), findsOneWidget);
    });

    testWidgets('shows empty reminders state when pet has none',
        (tester) async {
      final pet = petStore.activePet!;
      reminderStore.seed({pet.id ?? '': const []});

      await pumpDashboard(tester);

      expect(find.text('No reminders yet'), findsOneWidget);
    });

    testWidgets('tapping the reminders + icon opens the add-reminder sheet',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(Icons.add_circle_outline).last);
      await tester.pumpAndSettle();

      expect(find.byType(AddReminderSheet), findsOneWidget);
    });

    testWidgets('tapping a reminder tile opens it for editing', (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.text('Veterinary dentist'));
      await tester.pumpAndSettle();

      expect(find.byType(AddReminderSheet), findsOneWidget);
    });

    testWidgets('shows Measure and Trends action buttons', (tester) async {
      await pumpDashboard(tester);
      expect(find.text('Measure'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
    });

    testWidgets('shows empty state when no pets', (tester) async {
      petStore.seed(ownerPets: [], clinicPets: []);

      await pumpDashboard(tester);

      expect(find.text('No pets yet'), findsOneWidget);
      expect(
        find.text('Add your first pet to get started with health monitoring.'),
        findsOneWidget,
      );
    });
  });
}
