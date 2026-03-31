import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';

import '../helpers/test_app.dart';

void main() {
  group('RoundIconButton', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add, size: 16),
          onTap: () {},
        ),
      ));
      expect(find.byType(RoundIconButton), findsOneWidget);
    });

    // ── Variant tests ───────────────────────────────────────────────────────
    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add, size: 20),
          size: 48,
          iconSize: 20,
          onTap: () {},
        ),
      ));
      expect(find.byType(RoundIconButton), findsOneWidget);
    });

    testWidgets('renders with custom backgroundColor', (tester) async {
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add, size: 16),
          backgroundColor: Colors.red,
          onTap: () {},
        ),
      ));

      // Find the inner decorated Container with the color
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final decorated = containers.where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.color == Colors.red;
      });
      expect(decorated.isNotEmpty, isTrue);
    });

    // ── State tests ─────────────────────────────────────────────────────────
    testWidgets('disabled (onTap: null) does not respond to tap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add, size: 16),
          onTap: null,
        ),
      ));

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('enabled state shows InkWell', (tester) async {
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add, size: 16),
          onTap: () {},
        ),
      ));
      expect(find.byType(InkWell), findsOneWidget);
    });

    // ── Interaction test ────────────────────────────────────────────────────
    testWidgets('calls onTap when tapped', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add, size: 16),
          onTap: () => callCount++,
        ),
      ));

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(callCount, 1);
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('default bg is AppPrimitives.skyLight', (tester) async {
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add, size: 16),
          onTap: () {},
        ),
      ));

      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final withSkyLight = containers.where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.color == AppPrimitives.skyLight;
      });
      expect(withSkyLight.isNotEmpty, isTrue,
          reason: 'Default bg should be AppPrimitives.skyLight');
    });

    testWidgets('uses full border radius for InkWell', (tester) async {
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add, size: 16),
          onTap: () {},
        ),
      ));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, AppRadiiTokens.borderRadiusFull);
    });
  });
}
