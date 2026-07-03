import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/radio_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('RadioCard', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(testApp(
        const RadioCard(title: 'Option A'),
      ));
      expect(find.byType(RadioCard), findsOneWidget);
      expect(find.text('Option A'), findsOneWidget);
    });

    // ── Optional slots ──────────────────────────────────────────────────────
    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const RadioCard(
          title: 'Option A',
          description: 'A short description',
        ),
      ));
      expect(find.text('A short description'), findsOneWidget);
    });

    testWidgets('omits description when null', (tester) async {
      await tester.pumpWidget(testApp(
        const RadioCard(title: 'Option A'),
      ));
      // Only the title text should be rendered in this card.
      final cardFinder = find.byType(RadioCard);
      final texts = find.descendant(of: cardFinder, matching: find.byType(Text));
      expect(texts, findsOneWidget);
    });

    testWidgets('renders badge when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const RadioCard(
          title: 'Option A',
          badge: 'Active',
        ),
      ));
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('omits badge when null', (tester) async {
      await tester.pumpWidget(testApp(
        const RadioCard(title: 'Option A'),
      ));
      expect(find.text('Active'), findsNothing);
    });

    // ── Selected vs unselected visuals ──────────────────────────────────────
    testWidgets('selected variant shows purple border + filled dot',
        (tester) async {
      await tester.pumpWidget(testApp(
        const RadioCard(title: 'Selected', selected: true),
      ));

      final BuildContext context =
          tester.element(find.byType(RadioCard));
      final colors = AppSemanticColors.of(context);

      // The card itself has the purple border.
      final cardContainer = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(RadioCard),
          matching: find.byType(Container),
        ),
      );

      final hasPurpleBorderedContainer = cardContainer.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        final border = deco.border;
        if (border is! Border) return false;
        return border.top.color == colors.accentPurple &&
            border.top.width == 2;
      });
      expect(hasPurpleBorderedContainer, isTrue,
          reason: 'Selected card should have a 2px purple border');

      // Filled inner dot exists (12×12, purple).
      final filledDot = cardContainer.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.shape == BoxShape.circle &&
            deco.color == colors.accentPurple;
      });
      expect(filledDot, isTrue,
          reason: 'Selected card should have a filled purple inner dot');
    });

    testWidgets('unselected variant shows grey ring + empty dot',
        (tester) async {
      await tester.pumpWidget(testApp(
        const RadioCard(title: 'Unselected'),
      ));

      final BuildContext context =
          tester.element(find.byType(RadioCard));
      final colors = AppSemanticColors.of(context);

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(RadioCard),
          matching: find.byType(Container),
        ),
      );

      // Outer ring uses the hairline color.
      final hasHairlineRing = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        if (deco.shape != BoxShape.circle) return false;
        final border = deco.border;
        if (border is! Border) return false;
        return border.top.color == colors.hairline &&
            border.top.width == 2;
      });
      expect(hasHairlineRing, isTrue,
          reason:
              'Unselected card should have a 2px hairline ring on the radio dot');

      // No filled purple inner dot.
      final hasFilledPurpleDot = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.shape == BoxShape.circle &&
            deco.color == colors.accentPurple;
      });
      expect(hasFilledPurpleDot, isFalse,
          reason: 'Unselected card should not have a filled purple dot');

      // Card itself should not have the purple ring.
      final hasPurpleBorder = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        final border = deco.border;
        if (border is! Border) return false;
        return border.top.color == colors.accentPurple;
      });
      expect(hasPurpleBorder, isFalse,
          reason: 'Unselected card should not have a purple outer border');
    });

    // ── Interaction ─────────────────────────────────────────────────────────
    testWidgets('onTap fires when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(testApp(
        RadioCard(
          title: 'Tap me',
          onTap: () => tapped++,
        ),
      ));

      await tester.tap(find.byType(RadioCard));
      await tester.pumpAndSettle();

      expect(tapped, 1);
    });
  });
}
