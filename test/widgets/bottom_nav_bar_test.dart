import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    // ── All 4 tabs render (Circle hidden behind kEnableCircleTab) ──────────
    testWidgets('renders all 4 tab labels', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
      expect(find.text('Circle'), findsNothing);
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

    testWidgets('selecting index 2 highlights Measure tab', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 2, onTap: (_) {}),
      ));

      // With Circle hidden, index 2 is Measure (Home, Trends, Measure, Medication).
      final measureLabel = tester.widget<Text>(find.text('Measure'));
      expect(measureLabel.style?.color, AppSemanticColors.light.onSurface);

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

      // Medication is index 3 in the 4-tab layout (Circle hidden).
      await tester.tap(find.text('Medication'));
      await tester.pump();
      expect(tappedIndex, 3);
    });

    testWidgets('tapping Measure tab calls onTap with index 2',
        (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (i) => tappedIndex = i),
      ));

      await tester.tap(find.text('Measure'));
      await tester.pump();
      expect(tappedIndex, 2);
    });

    // ── Figma DS icons (node 500:1106) ──────────────────────────────────────
    testWidgets('uses the Figma nav SVGs for Home, Trends, Measure, Medicine',
        (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      final svgs = tester
          .widgetList<SvgPicture>(find.byType(SvgPicture))
          .map((s) => (s.bytesLoader as SvgAssetLoader).assetName)
          .toList();
      expect(svgs, containsAll([
        'assets/figma/nav_home.svg',
        'assets/figma/nav_trends.svg',
        'assets/figma/nav_measure.svg',
        'assets/figma/nav_medicine.svg',
      ]));
      // No Material Icon fallback for these 4 tabs anymore.
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('tints the active tab icon with onSurface, inactive with textTertiary',
        (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      final homeIcon = tester.widget<SvgPicture>(find.descendant(
        of: find.ancestor(
            of: find.text('Home'), matching: find.byType(GestureDetector)),
        matching: find.byType(SvgPicture),
      ));
      expect(homeIcon.colorFilter,
          ColorFilter.mode(AppSemanticColors.light.onSurface, BlendMode.srcIn));

      final trendsIcon = tester.widget<SvgPicture>(find.descendant(
        of: find.ancestor(
            of: find.text('Trends'), matching: find.byType(GestureDetector)),
        matching: find.byType(SvgPicture),
      ));
      expect(
          trendsIcon.colorFilter,
          ColorFilter.mode(
              AppSemanticColors.light.textTertiary, BlendMode.srcIn));
    });

    // ── Semantics ─────────────────────────────────────────────────────────
    testWidgets('each tab has a Semantics widget wrapping it', (tester) async {
      await tester.pumpWidget(testApp(
        BottomNavBar(selectedIndex: 0, onTap: (_) {}),
      ));

      // There should be 4 Semantics widgets with button: true (Circle hidden).
      final semanticsWidgets = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.button == true)
          .toList();
      expect(semanticsWidgets.length, 4);
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
