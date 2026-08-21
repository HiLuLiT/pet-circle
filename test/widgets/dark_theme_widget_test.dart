import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/shadows.dart';
import 'package:pet_circle/widgets/app_toggle.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';
import 'package:pet_circle/widgets/notification_card.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/status_badge.dart';

/// Renders the widgets that used to hold light-mode literals *inside the real
/// dark theme* and asserts what they actually paint.
///
/// These are the sites a screenshot would have caught. Asserting them instead
/// makes the check deterministic and permanent — per the project's
/// verify-design-via-assertions convention.
void main() {
  Widget darkHost(Widget child) => MaterialApp(
    theme: buildDarkTheme(),
    home: Scaffold(body: Center(child: child)),
  );

  Widget lightHost(Widget child) => MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: Center(child: child)),
  );

  BoxDecoration decorationOf(WidgetTester tester, Finder root) {
    final container = tester.widget<Container>(
      find.descendant(of: root, matching: find.byType(Container)).first,
    );
    return container.decoration! as BoxDecoration;
  }

  group('NotificationCard read state (the worst offender)', () {
    // Before this work it painted a hardcoded cream #EFEADF card with #6E6E6E
    // text, so a read notification was a light-on-light pill on near-black.
    const card = NotificationCard(
      icon: Icon(Icons.circle),
      iconTileColor: Color(0xFFC3AEF0),
      title: 'Read title',
      body: 'Read body',
      time: '1d ago',
    );

    testWidgets('background follows the dark recessed surface', (tester) async {
      await tester.pumpWidget(darkHost(card));
      final dec = decorationOf(tester, find.byType(NotificationCard));
      expect(dec.color, AppPrimitives.pcDarkWell);
      expect(dec.color, isNot(const Color(0xFFEFEADF)));
    });

    testWidgets('title follows the dark secondary ink', (tester) async {
      await tester.pumpWidget(darkHost(card));
      final title = tester.widget<Text>(find.text('Read title'));
      expect(title.style?.color, AppPrimitives.pcDarkInkSecondary);
      expect(title.style?.color, isNot(const Color(0xFF6E6E6E)));
    });

    testWidgets('light mode still uses the light tokens', (tester) async {
      await tester.pumpWidget(lightHost(card));
      final dec = decorationOf(tester, find.byType(NotificationCard));
      expect(dec.color, AppSemanticColors.light.surfaceRecessed);
      final title = tester.widget<Text>(find.text('Read title'));
      expect(title.style?.color, AppSemanticColors.light.textSecondary);
    });
  });

  group('AppToggle knob', () {
    testWidgets('knob is the dark ink, not Colors.white', (tester) async {
      await tester.pumpWidget(darkHost(const AppToggle(value: true)));
      final knob = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).shape == BoxShape.circle,
          );
      final color = (knob.decoration as BoxDecoration).color;
      expect(color, AppPrimitives.pcDarkInk);
    });

    testWidgets('knob stays white in light mode', (tester) async {
      await tester.pumpWidget(lightHost(const AppToggle(value: true)));
      final knob = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).shape == BoxShape.circle,
          );
      expect((knob.decoration as BoxDecoration).color, const Color(0xFFFFFFFF));
    });
  });

  group('PrimaryButton disabled state', () {
    testWidgets('uses the dark disabled surface, not the cream literal', (
      tester,
    ) async {
      await tester.pumpWidget(
        darkHost(const PrimaryButton(label: 'Save', onPressed: null)),
      );
      // The disabled fill reaches the button through ButtonStyle, so read it
      // off the resolved style rather than hunting for a Container.
      final button = tester.widget<TextButton>(find.byType(TextButton));
      final bg = button.style?.backgroundColor?.resolve({WidgetState.disabled});
      expect(bg, AppPrimitives.pcDarkElevated);
      expect(bg, isNot(const Color(0xFFE2DED5)));
    });

    testWidgets('light mode keeps the original literal exactly', (
      tester,
    ) async {
      await tester.pumpWidget(
        lightHost(const PrimaryButton(label: 'Save', onPressed: null)),
      );
      final button = tester.widget<TextButton>(find.byType(TextButton));
      final bg = button.style?.backgroundColor?.resolve({WidgetState.disabled});
      expect(bg, const Color(0xFFE2DED5));
    });
  });

  group('StatusBadge pills are dark chips, not light floodlights', () {
    for (final status in StatusBadgeStatus.values) {
      testWidgets('${status.name} pill uses a dark tile', (tester) async {
        await tester.pumpWidget(
          darkHost(StatusBadge(label: status.name, status: status)),
        );
        final dec = decorationOf(tester, find.byType(StatusBadge));
        // Every light pill background is above 0.5 luminance; every dark one
        // must be far below it.
        expect(
          dec.color!.computeLuminance(),
          lessThan(0.06),
          reason: '${status.name} pill is $dec.color — too bright for dark',
        );
      });
    }
  });

  group('shadows resolve per theme', () {
    testWidgets('a raised card uses the dark shadow set', (tester) async {
      await tester.pumpWidget(darkHost(const NeumorphicCard(child: Text('x'))));
      final dec = decorationOf(tester, find.byType(NeumorphicCard));
      expect(dec.boxShadow, AppShadowTokens.darkSmall);
    });

    testWidgets('a raised card uses the light shadow set in light', (
      tester,
    ) async {
      await tester.pumpWidget(
        lightHost(const NeumorphicCard(child: Text('x'))),
      );
      final dec = decorationOf(tester, find.byType(NeumorphicCard));
      expect(dec.boxShadow, AppShadowTokens.small);
    });
  });
}
