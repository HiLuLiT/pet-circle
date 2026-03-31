import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/shadows.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('NeumorphicCard', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const NeumorphicCard(child: Text('Hello')),
      ));
      expect(find.byType(NeumorphicCard), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    // ── Variant tests ───────────────────────────────────────────────────────
    testWidgets('outer variant (inner=false) renders child', (tester) async {
      await tester.pumpWidget(testApp(
        const NeumorphicCard(inner: false, child: Text('Outer')),
      ));
      expect(find.text('Outer'), findsOneWidget);
    });

    testWidgets('inner variant (inner=true) renders child', (tester) async {
      await tester.pumpWidget(testApp(
        const NeumorphicCard(inner: true, child: Text('Inner')),
      ));
      expect(find.text('Inner'), findsOneWidget);
    });

    // ── State tests ─────────────────────────────────────────────────────────
    testWidgets('accepts custom padding and margin', (tester) async {
      await tester.pumpWidget(testApp(
        const NeumorphicCard(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(10),
          child: Text('Padded'),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      expect(container.padding, const EdgeInsets.all(20));
      expect(container.margin, const EdgeInsets.all(10));
    });

    testWidgets('accepts custom color', (tester) async {
      await tester.pumpWidget(testApp(
        const NeumorphicCard(
          color: Colors.red,
          child: Text('Red'),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('accepts custom radius', (tester) async {
      final customRadius = BorderRadius.circular(99);
      await tester.pumpWidget(testApp(
        NeumorphicCard(
          radius: customRadius,
          child: const Text('Custom'),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, customRadius);
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('default bg uses semantic surface color', (tester) async {
      await tester.pumpWidget(testApp(
        const NeumorphicCard(child: Text('Default')),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.surface);
    });

    testWidgets('uses AppShadowTokens.small (not neumorphic)', (tester) async {
      await tester.pumpWidget(testApp(
        const NeumorphicCard(child: Text('Shadow')),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, AppShadowTokens.small);
    });

    testWidgets('default radius uses AppRadiiTokens.borderRadiusLg',
        (tester) async {
      await tester.pumpWidget(testApp(
        const NeumorphicCard(child: Text('Radius')),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, AppRadiiTokens.borderRadiusLg);
    });

    // ── Interaction test (card is non-interactive, but verify child) ────────
    testWidgets('child interaction works through card', (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        NeumorphicCard(
          child: GestureDetector(
            onTap: () => tapped = true,
            child: const Text('Tap'),
          ),
        ),
      ));

      await tester.tap(find.text('Tap'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
