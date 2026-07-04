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

    testWidgets('shows manual mode without the vision mode tab', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // VisionRR camera mode is hidden behind kEnableVisionRR, so the
      // manual/vision tab selector is not rendered — manual mode shows directly.
      expect(find.byIcon(Icons.videocam_outlined), findsNothing);
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

    testWidgets('shows tap-to-begin state before the timer starts',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // DS alignment: before the timer starts, the tap circle shows a heart
      // icon + "Tap to begin" — the numeric tap count only appears once
      // isRunning is true.
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows elapsed time next to the duration progress track',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // DS alignment: the timer card now shows elapsed seconds (starting at
      // "0s") next to a progress track, rather than a large remaining-time
      // countdown. "60s" only appears once now, as the selected duration chip.
      expect(find.text('0s'), findsOneWidget);
      expect(find.text('60s'), findsOneWidget);
    });
  });
}
