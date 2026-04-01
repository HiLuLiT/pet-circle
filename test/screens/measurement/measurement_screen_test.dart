import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/measurement/measurement_screen.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('MeasurementScreen', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementScreen), findsOneWidget);
    });

    testWidgets('shows manual and vision mode tabs', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // Manual mode tab
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
      // Vision mode tab
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    });

    testWidgets('shows timer duration selector with duration chips',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // Duration chips: 15s, 30s, 60s
      expect(find.text('15s'), findsOneWidget);
      expect(find.text('30s'), findsOneWidget);
      // 60s appears both as a chip and in the timer display
      expect(find.text('60s'), findsAtLeast(1));
    });

    testWidgets('shows tap counter circle with initial count of 0',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // Initial tap count is 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('shows remaining time as large countdown text', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // The timer display shows remaining seconds — default 60s appears
      // as both the chip label and the countdown, so at least 2 instances
      expect(find.text('60s'), findsNWidgets(2));
    });
  });
}
