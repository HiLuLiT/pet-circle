import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/status_badge.dart';

import '../helpers/test_app.dart';

/// Finds the outermost pill Container inside a StatusBadge (the one with a
/// BoxDecoration whose borderRadius is the PC pill radius).
Container _pillContainer(WidgetTester tester) {
  return tester
      .widgetList<Container>(find.descendant(
        of: find.byType(StatusBadge),
        matching: find.byType(Container),
      ))
      .firstWhere((c) {
    final d = c.decoration;
    if (d is! BoxDecoration) return false;
    return d.borderRadius == BorderRadius.circular(AppRadiiTokens.pcPill);
  });
}

void main() {
  group('StatusBadge', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'OK', color: AppPrimitives.greenBase),
      ));
      expect(find.byType(StatusBadge), findsOneWidget);
    });

    // ── Status inference from legacy `color` parameter ──────────────────────
    testWidgets('infers active (mint) status from greenBase', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Normal', color: AppPrimitives.greenBase),
      ));
      final pill = _pillContainer(tester);
      final decoration = pill.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.statusActiveBg);
      // Active variant: no 9x9 dot.
      final dots = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(StatusBadge),
            matching: find.byType(Container),
          ))
          .where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.shape == BoxShape.circle;
      });
      expect(dots, isEmpty);
    });

    testWidgets('infers elevated (butter) status from yellowLightest',
        (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(
            label: 'Elevated', color: AppPrimitives.yellowLightest),
      ));
      final pill = _pillContainer(tester);
      final decoration = pill.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.statusElevatedBg);
    });

    testWidgets('infers alert (blush) status from redBase', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Critical', color: AppPrimitives.redBase),
      ));
      final pill = _pillContainer(tester);
      final decoration = pill.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.statusAlertBg);
    });

    testWidgets('infers normal (periwinkle) status from blueBase',
        (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Info', color: AppPrimitives.blueBase),
      ));
      final pill = _pillContainer(tester);
      final decoration = pill.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.statusNormalBg);
    });

    // ── Explicit status param overrides color inference ─────────────────────
    testWidgets('explicit status param overrides color', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(
          label: 'Forced',
          color: AppPrimitives.greenBase, // would infer active
          status: StatusBadgeStatus.alert, // but explicit wins
        ),
      ));
      final pill = _pillContainer(tester);
      final decoration = pill.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.statusAlertBg);
    });

    // ── Dot behaviour ────────────────────────────────────────────────────────
    testWidgets('renders 9x9 dot for non-active variants', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(
          label: 'Normal',
          status: StatusBadgeStatus.normal,
        ),
      ));
      final dots = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(StatusBadge),
            matching: find.byType(Container),
          ))
          .where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.shape == BoxShape.circle;
      }).toList();
      expect(dots, hasLength(1));
      expect(dots.first.constraints?.maxWidth ?? 0, anyOf(9.0, isNaN));
    });

    testWidgets('omits dot for active variant', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(
          label: 'Active',
          status: StatusBadgeStatus.active,
        ),
      ));
      final dots = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(StatusBadge),
            matching: find.byType(Container),
          ))
          .where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.shape == BoxShape.circle;
      });
      expect(dots, isEmpty);
    });

    // ── Invited variant (yellow, no dot) ─────────────────────────────────────
    testWidgets('renders label for invited variant', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(
          label: 'Invited',
          status: StatusBadgeStatus.invited,
        ),
      ));
      expect(find.text('Invited'), findsOneWidget);
    });

    testWidgets('invited variant uses statusInvitedBg background',
        (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(
          label: 'Invited',
          status: StatusBadgeStatus.invited,
        ),
      ));
      final pill = _pillContainer(tester);
      final decoration = pill.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.statusInvitedBg);
    });

    testWidgets('invited variant uses statusInvitedText text color',
        (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(
          label: 'Invited',
          status: StatusBadgeStatus.invited,
        ),
      ));
      final text = tester.widget<Text>(find.text('Invited'));
      expect(text.style?.color, AppSemanticColors.light.statusInvitedText);
    });

    testWidgets('omits dot for invited variant', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(
          label: 'Invited',
          status: StatusBadgeStatus.invited,
        ),
      ));
      final dots = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(StatusBadge),
            matching: find.byType(Container),
          ))
          .where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.shape == BoxShape.circle;
      });
      expect(dots, isEmpty);
    });

    // ── State tests (label text) ────────────────────────────────────────────
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Active', color: AppPrimitives.primaryBase),
      ));
      expect(find.text('Active'), findsOneWidget);
    });

    // ── Interaction test (badge is non-interactive) ─────────────────────────
    testWidgets('is non-interactive (no InkWell or GestureDetector)',
        (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Test', color: AppPrimitives.blueBase),
      ));
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('uses Instrument Sans 13/700 typography', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Token', color: AppPrimitives.primaryBase),
      ));

      final text = tester.widget<Text>(find.text('Token'));
      expect(text.style?.fontSize, 13);
      expect(text.style?.fontWeight, FontWeight.w700);
      expect(text.style?.fontFamily, 'Instrument Sans');
    });

    testWidgets('uses pill border radius (9999)', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Pill', color: AppPrimitives.primaryBase),
      ));
      final pill = _pillContainer(tester);
      final decoration = pill.decoration as BoxDecoration;
      expect(decoration.borderRadius,
          BorderRadius.circular(AppRadiiTokens.pcPill));
    });

    testWidgets('text color matches active status text token', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Color', color: AppPrimitives.primaryBase),
      ));
      final text = tester.widget<Text>(find.text('Color'));
      expect(text.style?.color, AppSemanticColors.light.statusActiveText);
    });
  });
}
