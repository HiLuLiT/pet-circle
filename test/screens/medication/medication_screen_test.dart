import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/medication/medication_screen.dart';

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
}
