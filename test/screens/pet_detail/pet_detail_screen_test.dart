import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_screen.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_sections.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/note_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/widgets/status_badge.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  Pet testPet() => petStore.ownerPets.first;

  group('PetDetailScreen', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        // Suppress overflow and network image errors in tests.
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) {
          errors.add(details);
          return;
        }
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: testPet())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PetDetailScreen), findsOneWidget);
    });

    testWidgets('shows pet name in app bar', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) return;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      final pet = testPet();
      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: pet)),
      );
      await tester.pumpAndSettle();

      expect(find.text(pet.name), findsOneWidget);
    });

    testWidgets('shows breed and age', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) return;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      final pet = testPet();
      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: pet)),
      );
      await tester.pumpAndSettle();

      expect(find.text(pet.breedAndAge), findsOneWidget);
    });

    testWidgets('shows status badge', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) return;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      final pet = testPet();
      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: pet)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text(pet.statusLabel), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) return;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: testPet())),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Shared error suppression helper
  // ---------------------------------------------------------------------------
  void suppressErrors(WidgetTester tester) {
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('overflowed') || msg.contains('HTTP request failed')) return;
      oldHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = oldHandler);
  }

  void setViewSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(600, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // ---------------------------------------------------------------------------
  // PetDetailScreen — sections visible
  // ---------------------------------------------------------------------------
  group('PetDetailScreen — sections visible', () {
    testWidgets('shows latest reading section', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.text('Latest Reading'), findsOneWidget);
    });

    testWidgets('shows measurement history section', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.text('Measurement History'), findsOneWidget);
    });

    testWidgets('shows clinical notes section', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.text('Clinical Notes'), findsOneWidget);
    });

    testWidgets('shows care circle section', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.text('Care Circle'), findsOneWidget);
    });

    testWidgets('shows add note button', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.text('Add Note'), findsOneWidget);
    });

    testWidgets('shows PetInfoSection widget', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.byType(PetInfoSection), findsOneWidget);
    });

    testWidgets('shows PetMeasurementHistory widget', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.byType(PetMeasurementHistory), findsOneWidget);
    });

    testWidgets('shows PetClinicalNotes widget', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.byType(PetClinicalNotes), findsOneWidget);
    });

    testWidgets('shows PetCareCircle widget', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.byType(PetCareCircle), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // PetDetailScreen — with measurements
  // ---------------------------------------------------------------------------
  group('PetDetailScreen — with measurements', () {
    testWidgets('shows bpm value when measurements exist', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      final pet = testPet();
      // Re-seed with a specific bpm; it appears in both the InfoTile and the bar chart
      measurementStore.seed({
        pet.id!: [
          Measurement(bpm: 28, recordedAt: DateTime.now()),
        ],
      });

      await tester.pumpWidget(testApp(PetDetailScreen(pet: pet)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The bpm '28' appears in the latest reading InfoTile and the bar chart label
      expect(find.text('28'), findsWidgets);
    });

    testWidgets('shows -- when no measurements and pet bpm == 0', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      final basePet = testPet();
      final noBpmPet = basePet.copyWith(
        latestMeasurement: Measurement(
          bpm: 0,
          recordedAt: DateTime(2025, 1, 1),
          recordedAtLabel: 'No measurements yet',
        ),
      );
      petStore.updatePet(basePet.name, noBpmPet);
      measurementStore.seed({basePet.id!: []});

      await tester.pumpWidget(testApp(PetDetailScreen(pet: noBpmPet)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('--'), findsWidgets);
    });

    testWidgets('shows BPM label in info section', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.text('BPM'), findsOneWidget);
    });

    testWidgets('shows View Graph button in measurement history', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.text('View Graph'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // PetDetailScreen — no notes state
  // ---------------------------------------------------------------------------
  group('PetDetailScreen — empty notes state', () {
    testWidgets('shows no clinical notes message when notes empty', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      final pet = testPet();
      noteStore.seed({pet.id!: []});

      await tester.pumpWidget(testApp(PetDetailScreen(pet: pet)));
      await tester.pumpAndSettle();

      expect(find.text('No clinical notes yet'), findsOneWidget);
    });

    testWidgets('shows existing note content when notes seeded', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      // seedAllStores already seeds princessNotes
      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      // The seeded note from MockData should be visible
      expect(find.textContaining('Respiratory rate stable'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // PetDetailScreen — edit action
  // ---------------------------------------------------------------------------
  group('PetDetailScreen — edit action', () {
    testWidgets('shows edit icon button in app bar for owner', (tester) async {
      setViewSize(tester);
      suppressErrors(tester);

      await tester.pumpWidget(testApp(PetDetailScreen(pet: testPet())));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}
