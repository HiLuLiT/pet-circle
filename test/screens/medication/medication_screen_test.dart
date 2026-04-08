import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/screens/medication/medication_screen.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/pet_store.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('MedicationScreen', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(MedicationScreen), findsOneWidget);
    });

    testWidgets('shows medication management title', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Medication Management'), findsOneWidget);
    });

    testWidgets('shows add medication button', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add Medication'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows empty state when no medications exist', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      // Empty state shows no medications recorded message
      expect(find.text('No Medications Recorded'), findsOneWidget);
    });

    testWidgets('shows export medication log button', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Export Medication Log'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // MedicationScreen — with medications seeded
  // ---------------------------------------------------------------------------
  group('MedicationScreen — with medications', () {
    late String petId;

    setUp(() {
      seedAllStores();
      petId = petStore.ownerPets.first.id!;
      medicationStore.seed({
        petId: [
          Medication(
            id: 'med-test-1',
            name: 'Furosemide',
            dosage: '10mg',
            frequency: 'Twice daily',
            startDate: DateTime(2025, 1, 15),
            isActive: true,
          ),
          Medication(
            id: 'med-test-2',
            name: 'Enalapril',
            dosage: '5mg',
            frequency: 'Once daily',
            startDate: DateTime(2025, 3, 1),
            isActive: false,
          ),
        ],
      });
    });

    void setViewSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('renders medication names in list', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Furosemide'), findsOneWidget);
      expect(find.text('Enalapril'), findsOneWidget);
    });

    testWidgets('shows dosage and frequency for each medication', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('10mg • Twice daily'), findsOneWidget);
      expect(find.text('5mg • Once daily'), findsOneWidget);
    });

    testWidgets('shows active status badge for active medication', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows done badge for inactive medication', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('displays active treatment count in subtitle', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      // Active count: 1 (Furosemide is active, Enalapril is not)
      expect(find.textContaining('1 active treatments'), findsOneWidget);
    });

    testWidgets('does not show empty state when medications exist', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No Medications Recorded'), findsNothing);
    });

    testWidgets('medication card shows start date', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      // Date formatted as month/day: 1/15 for Furosemide
      expect(find.text('1/15'), findsOneWidget);
    });

    testWidgets('shows medication icon for each card', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.medication), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // MedicationScreen — export dialog
  // ---------------------------------------------------------------------------
  group('MedicationScreen — export dialog', () {
    void setViewSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('tapping export button opens dialog with csv preview', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      // Use the TextButton.icon with file_download icon to target the export button
      final exportBtn = find.byIcon(Icons.file_download);
      expect(exportBtn, findsOneWidget);
      await tester.tap(exportBtn);
      await tester.pumpAndSettle();

      // Dialog should appear with CSV Preview label
      expect(find.text('CSV Preview:'), findsOneWidget);
    });

    testWidgets('export dialog has close and download buttons', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Download CSV'), findsOneWidget);
    });

    testWidgets('close button dismisses export dialog', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('CSV Preview:'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // MedicationScreen — no scaffold variant
  // ---------------------------------------------------------------------------
  group('MedicationScreen — showScaffold=false', () {
    testWidgets('renders without Scaffold when showScaffold is false', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(const MedicationScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MedicationScreen), findsOneWidget);
      expect(find.text('Medication Management'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // MedicationScreen — clinical record info section
  // ---------------------------------------------------------------------------
  group('MedicationScreen — clinical record section', () {
    void setViewSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('shows clinical record information heading', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Clinical Record Information'), findsOneWidget);
    });

    testWidgets('shows info outline icon in clinical record section', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows file download icon for export button', (tester) async {
      setViewSize(tester);
      await tester.pumpWidget(testApp(const MedicationScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_download), findsOneWidget);
    });
  });
}
