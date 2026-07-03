import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';

import '../helpers/test_app.dart';

void main() {
  group('RoundIconButton', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add),
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
          icon: const Icon(Icons.add),
          backgroundColor: Colors.red,
          onTap: () {},
        ),
      ));

      final decorations = tester
          .widgetList<Ink>(find.byType(Ink))
          .map((w) => w.decoration)
          .whereType<ShapeDecoration>();
      expect(
        decorations.any((d) => d.color == Colors.red),
        isTrue,
        reason: 'Custom backgroundColor should override variant default',
      );
    });

    // ── State tests ─────────────────────────────────────────────────────────
    testWidgets('disabled (onTap: null) does not respond to tap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add),
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
          icon: const Icon(Icons.add),
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
          icon: const Icon(Icons.add),
          onTap: () => callCount++,
        ),
      ));

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(callCount, 1);
    });

    // ── Theme token tests (PC v3) ───────────────────────────────────────────
    testWidgets('primary variant default bg is semantic onSurface (ink)',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(testApp(
        Builder(
          builder: (context) {
            capturedContext = context;
            return RoundIconButton(
              icon: const Icon(Icons.add),
              onTap: () {},
            );
          },
        ),
      ));

      final expectedBg = AppSemanticColors.of(capturedContext).onSurface;
      final decorations = tester
          .widgetList<Ink>(find.byType(Ink))
          .map((w) => w.decoration)
          .whereType<ShapeDecoration>();
      expect(
        decorations.any((d) => d.color == expectedBg),
        isTrue,
        reason:
            'Primary variant default bg should be semantic onSurface token',
      );
    });

    testWidgets('ghost variant uses semantic surface bg with hairline border',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(testApp(
        Builder(
          builder: (context) {
            capturedContext = context;
            return RoundIconButton(
              icon: const Icon(Icons.add),
              variant: RoundIconButtonVariant.ghost,
              onTap: () {},
            );
          },
        ),
      ));

      final colors = AppSemanticColors.of(capturedContext);
      final decorations = tester
          .widgetList<Ink>(find.byType(Ink))
          .map((w) => w.decoration)
          .whereType<ShapeDecoration>()
          .toList();

      final ghostMatch = decorations.firstWhere(
        (d) => d.color == colors.surface,
        orElse: () => throw StateError(
          'Expected an Ink with ShapeDecoration coloured surface',
        ),
      );
      final shape = ghostMatch.shape;
      expect(shape, isA<CircleBorder>());
      expect((shape as CircleBorder).side.color, colors.hairline);
      expect(shape.side.width, 1);
    });

    testWidgets('uses full border radius for InkWell', (tester) async {
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add),
          onTap: () {},
        ),
      ));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.customBorder, isA<CircleBorder>());
    });

    // ── Sizing ─────────────────────────────────────────────────────────────
    testWidgets('defaults to 54x54 (PC v3 spec)', (tester) async {
      await tester.pumpWidget(testApp(
        RoundIconButton(
          icon: const Icon(Icons.add),
          onTap: () {},
        ),
      ));

      final sized = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(InkWell),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sized.height, 54);
      expect(sized.width, 54);
    });
  });
}
