import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/medication/add_medication_sheet.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('AddMedicationSheet', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.byType(AddMedicationSheet), findsOneWidget);
    });

    testWidgets('shows add new medication title when creating',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Add New Medication'), findsOneWidget);
    });

    testWidgets('shows required form fields', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      // Required fields
      expect(find.text('Medication Name *'), findsOneWidget);
      expect(find.text('Dosage *'), findsOneWidget);
      expect(find.text('Frequency *'), findsOneWidget);
      expect(find.text('Start Date *'), findsOneWidget);
    });

    testWidgets('shows optional form fields', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Additional Notes'), findsOneWidget);
    });

    testWidgets(
        'does not show fields outside the Figma spec (Prescribed By, '
        'Purpose/Condition, Reminders)', (tester) async {
      // DS alignment (Figma node 402-2388): these fields aren't part of the
      // "Add medication" drawer design and were removed from the form.
      // Existing records keep whatever values they already had (preserved
      // via copyWith on save) — this only removes the ability to set them.
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Prescribed By'), findsNothing);
      expect(find.text('Purpose / Condition'), findsNothing);
      expect(find.text('Medication Reminders'), findsNothing);
    });

    testWidgets('shows cancel and add medication buttons', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add Medication'), findsOneWidget);
    });
  });
}
