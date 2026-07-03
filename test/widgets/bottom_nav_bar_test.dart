import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/bottom_nav_bar.dart';

import '../helpers/test_app.dart';

void main() {
  group('BottomNavBar', () {
    // ── Smoke ─────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));
      expect(find.byType(BottomNavBar), findsOneWidget);
    });

    // ── All 5 tabs render ─────────────────────────────────────────────────
    testWidgets('renders all 5 tab labels', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
      expect(find.text('Circle'), findsOneWidget);
      expect(find.text('Measure'), findsOneWidget);
      expect(find.text('Medication'), findsOneWidget);
    });

    // ── Active state ──────────────────────────────────────────────────────
    testWidgets('active tab uses onSurface (ink) color', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      final homeLabel = tester.widget<Text>(find.text('Home'));
      expect(homeLabel.style?.color, AppSemanticColors.light.onSurface);
    });

    testWidgets('inactive tab uses textTertiary color', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      // "Trends" is not selected (index 1, selected is 0)
      final trendsLabel = tester.widget<Text>(find.text('Trends'));
      expect(trendsLabel.style?.color, AppSemanticColors.light.textTertiary);
    });

    testWidgets('selecting index 2 highlights Circle tab', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 2, onTap: (_) {}),
      ));

      final diaryLabel = tester.widget<Text>(find.text('Circle'));
      expect(diaryLabel.style?.color, AppSemanticColors.light.onSurface);

      final homeLabel = tester.widget<Text>(find.text('Home'));
      expect(homeLabel.style?.color, AppSemanticColors.light.textTertiary);
    });

    // ── Interaction ───────────────────────────────────────────────────────
    testWidgets('tapping a tab calls onTap with correct index',
        (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (i) => tappedIndex = i),
      ));

      await tester.tap(find.text('Medication'));
      await tester.pump();
      expect(tappedIndex, 4);
    });

    testWidgets('tapping Circle tab calls onTap with index 2',
        (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (i) => tappedIndex = i),
      ));

      await tester.tap(find.text('Circle'));
      await tester.pump();
      expect(tappedIndex, 2);
    });

    // ── Semantics ─────────────────────────────────────────────────────────
    testWidgets('each tab has a Semantics widget wrapping it', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      // There should be 5 Semantics widgets with button: true
      final semanticsWidgets = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.button == true)
          .toList();
      expect(semanticsWidgets.length, 5);
    });

    // ── Theme token verification ──────────────────────────────────────────
    testWidgets('background is translucent surface', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BottomNavBar),
          matching: find.byType(Container).first,
        ),
      );
      expect(
        container.color,
        AppSemanticColors.light.surface.withValues(alpha: 0.92),
      );
    });
  });
}
