import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/screens/measurement/measurement_screen.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';

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

    testWidgets(
        'Last reading card refreshes as soon as a new measurement is saved '
        '(BUG-033 — was stuck on the value from first build)',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // Seeded mock data already has a latest reading of 22 BPM for the
      // active pet (see MockData.princessMeasurements).
      expect(find.text('22'), findsOneWidget);
      expect(find.text('99'), findsNothing);

      final petId = petStore.activePet!.id!;
      // seed() (a pure local mutation + notifyListeners(), no Firestore
      // write) is used here rather than addMeasurement() -- the latter
      // optimistically inserts then rolls back once its Firestore write
      // fails in this Firebase-less test environment, which would make
      // this assertion flaky/order-dependent on exactly when that
      // rejection resolves relative to pump(). seed() isolates the one
      // thing this test needs to prove: the screen rebuilds off
      // measurementStore.notifyListeners(), not just petStore/userStore.
      measurementStore.seed({
        petId: [
          Measurement(bpm: 99, recordedAt: DateTime.now()),
          ...measurementStore.getMeasurements(petId),
        ],
      });
      await tester.pump();

      expect(find.text('99'), findsOneWidget);
      expect(find.text('22'), findsNothing);
    });

    testWidgets('stop button is absent before timing starts', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.stop_rounded), findsNothing);
      expect(find.byIcon(Icons.replay_rounded), findsNothing);
    });

    testWidgets('stop button appears once timing starts', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // Tap the circle (the GestureDetector wrapping the heart icon).
      final circleGesture = find.ancestor(
        of: find.byIcon(Icons.favorite),
        matching: find.byType(GestureDetector),
      ).first;
      await tester.tap(circleGesture);
      await tester.pump();

      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.byIcon(Icons.replay_rounded), findsNothing);
    });

    testWidgets('stop button shows restart icon after being tapped',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // Tap the circle (ancestor of the heart icon) to start timing.
      final circleGesture = find.ancestor(
        of: find.byIcon(Icons.favorite),
        matching: find.byType(GestureDetector),
      ).first;
      await tester.tap(circleGesture);
      await tester.pump();

      // Stop button should now be present; tap it.
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pump();

      // Timer is cancelled: stop icon gone, restart icon appears.
      expect(find.byIcon(Icons.stop_rounded), findsNothing);
      expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
    });

    testWidgets('restart button resets to ready state without auto-starting',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const MeasurementScreen()));
      await tester.pumpAndSettle();

      // Tap the circle to start.
      final circleGesture = find.ancestor(
        of: find.byIcon(Icons.favorite),
        matching: find.byType(GestureDetector),
      ).first;
      await tester.tap(circleGesture);
      await tester.pump();

      // Tap stop.
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pump();

      // Tap restart.
      await tester.tap(find.byIcon(Icons.replay_rounded));
      await tester.pump();

      // Back to ready state: heart icon visible, no stop/restart buttons.
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsNothing);
      expect(find.byIcon(Icons.replay_rounded), findsNothing);

      // Pump some time — elapsed should stay at 0s (not auto-started).
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('0s'), findsOneWidget);
    });
  });
}
