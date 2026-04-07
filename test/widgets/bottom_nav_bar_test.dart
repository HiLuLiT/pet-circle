import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
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
      expect(find.text('Mesure'), findsOneWidget);
      expect(find.text('Medicine'), findsOneWidget);
    });

    // ── Active state ──────────────────────────────────────────────────────
    testWidgets('active tab uses primary color', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      // The "Home" label text should use the primary color.
      final homeLabel = tester.widget<Text>(find.text('Home'));
      expect(homeLabel.style?.color, AppSemanticColors.light.primary);
    });

    testWidgets('inactive tab uses inkLight color', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      // "Trends" is not selected (index 1, selected is 0)
      final trendsLabel = tester.widget<Text>(find.text('Trends'));
      expect(trendsLabel.style?.color, AppPrimitives.inkLight);
    });

    testWidgets('selecting index 2 highlights Circle tab', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 2, onTap: (_) {}),
      ));

      final diaryLabel = tester.widget<Text>(find.text('Circle'));
      expect(diaryLabel.style?.color, AppSemanticColors.light.primary);

      final homeLabel = tester.widget<Text>(find.text('Home'));
      expect(homeLabel.style?.color, AppPrimitives.inkLight);
    });

    // ── Interaction ───────────────────────────────────────────────────────
    testWidgets('tapping a tab calls onTap with correct index',
        (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (i) => tappedIndex = i),
      ));

      await tester.tap(find.text('Medicine'));
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
    testWidgets('background is white', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BottomNavBar),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppPrimitives.skyWhite);
    });
  });
}
