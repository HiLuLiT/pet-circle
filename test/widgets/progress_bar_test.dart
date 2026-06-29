import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/progress_bar.dart';

import '../helpers/test_app.dart';

/// Reads the rendered fraction of the fill indicator (the
/// [FractionallySizedBox] inside [ProgressBar]).
double _fillWidthFactor(WidgetTester tester) {
  final box = tester.widget<FractionallySizedBox>(
    find.descendant(
      of: find.byType(ProgressBar),
      matching: find.byType(FractionallySizedBox),
    ),
  );
  return box.widthFactor!;
}

/// Returns the [BoxDecoration] color of the track (first [Container]) and the
/// fill (the [Container] inside the [FractionallySizedBox]).
({Color track, Color fill}) _barColors(WidgetTester tester) {
  final track = tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(ProgressBar),
          matching: find.byType(Container),
        ),
      )
      .first;
  final fill = tester.widget<Container>(
    find.descendant(
      of: find.byType(FractionallySizedBox),
      matching: find.byType(Container),
    ),
  );
  return (
    track: (track.decoration as BoxDecoration).color!,
    fill: (fill.decoration as BoxDecoration).color!,
  );
}

void main() {
  group('ProgressBar', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(const ProgressBar(value: 0.5)));

      expect(find.byType(ProgressBar), findsOneWidget);
    });

    // ── Value clamping ────────────────────────────────────────────────────
    testWidgets('clamps value above 1.0 to 1.0', (tester) async {
      await tester.pumpWidget(testApp(const ProgressBar(value: 1.5)));

      expect(_fillWidthFactor(tester), 1.0);
    });

    testWidgets('clamps negative value to 0.0', (tester) async {
      await tester.pumpWidget(testApp(const ProgressBar(value: -0.4)));

      expect(_fillWidthFactor(tester), 0.0);
    });

    // ── Fill width reflects value ───────────────────────────────────────────
    testWidgets('fill width factor reflects value', (tester) async {
      await tester.pumpWidget(testApp(const ProgressBar(value: 0.25)));
      expect(_fillWidthFactor(tester), 0.25);

      await tester.pumpWidget(testApp(const ProgressBar(value: 0.75)));
      expect(_fillWidthFactor(tester), 0.75);
    });

    // ── Default colors ──────────────────────────────────────────────────────
    testWidgets('uses semantic tokens by default', (tester) async {
      await tester.pumpWidget(testApp(const ProgressBar(value: 0.5)));

      final colors = _barColors(tester);
      expect(colors.track, AppSemanticColors.light.surfaceRecessed);
      expect(colors.fill, AppSemanticColors.light.primary);
    });

    // ── Custom colors ─────────────────────────────────────────────────────
    testWidgets('honors custom track and fill colors', (tester) async {
      const customTrack = Color(0xFF112233);
      const customFill = Color(0xFF445566);
      await tester.pumpWidget(
        testApp(
          const ProgressBar(
            value: 0.5,
            trackColor: customTrack,
            fillColor: customFill,
          ),
        ),
      );

      final colors = _barColors(tester);
      expect(colors.track, customTrack);
      expect(colors.fill, customFill);
    });
  });
}
