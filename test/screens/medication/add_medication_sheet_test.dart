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

      expect(find.text('Prescribed By'), findsOneWidget);
      expect(find.text('Purpose / Condition'), findsOneWidget);
      expect(find.text('Additional Notes'), findsOneWidget);
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
