import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/app_header.dart';
import 'package:pet_circle/widgets/user_avatar.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppHeader', () {
    // ── Smoke ─────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(const AppHeader(userName: 'Alice')));
      expect(find.byType(AppHeader), findsOneWidget);
    });

    // ── Avatar ────────────────────────────────────────────────────────────
    testWidgets('renders UserAvatar with provided name', (tester) async {
      await tester.pumpWidget(testApp(const AppHeader(userName: 'Bob')));
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    // ── Pet selector ──────────────────────────────────────────────────────
    testWidgets('shows pet name when petName is provided', (tester) async {
      await tester.pumpWidget(
        testApp(const AppHeader(userName: 'Alice', petName: 'Buddy')),
      );
      expect(find.text('Buddy'), findsOneWidget);
    });

    testWidgets('hides pet selector when petName is null', (tester) async {
      await tester.pumpWidget(testApp(const AppHeader(userName: 'Alice')));
      expect(find.text('Buddy'), findsNothing);
    });

    testWidgets('shows dropdown icon when onPetSelectorTap is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          AppHeader(
            userName: 'Alice',
            petName: 'Buddy',
            onPetSelectorTap: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    // ── Notification bell ─────────────────────────────────────────────────
    testWidgets('renders notification icon', (tester) async {
      await tester.pumpWidget(testApp(const AppHeader(userName: 'Alice')));
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    // ── Interaction ───────────────────────────────────────────────────────
    testWidgets('tapping notification bell calls onNotificationTap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        testApp(
          AppHeader(userName: 'Alice', onNotificationTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byIcon(Icons.notifications_none));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('tapping pet selector calls onPetSelectorTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        testApp(
          AppHeader(
            userName: 'Alice',
            petName: 'Buddy',
            onPetSelectorTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Buddy'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    // ── Theme token verification ──────────────────────────────────────────
    testWidgets('notification bell is a white pill with no shadow', (
      tester,
    ) async {
      await tester.pumpWidget(testApp(const AppHeader(userName: 'Alice')));

      // Figma 442:8694 is a white pill with 12px padding around a 16.615px
      // glyph and NO shadow — the previous drop shadow was not in the design.
      final bells = tester.widgetList<Container>(find.byType(Container)).where((
        c,
      ) {
        final dec = c.decoration;
        return dec is BoxDecoration &&
            dec.color == AppSemanticColors.light.surface &&
            dec.borderRadius != null;
      }).toList();
      expect(bells, isNotEmpty, reason: 'bell pill not found');
      final dec = bells.first.decoration! as BoxDecoration;
      expect(
        dec.boxShadow ?? const <BoxShadow>[],
        isEmpty,
        reason: 'Figma 442:8694 specifies no shadow on the bell',
      );
      expect(bells.first.padding, const EdgeInsets.all(12));

      final icon = tester.widget<Icon>(find.byIcon(Icons.notifications_none));
      expect(icon.size, closeTo(16.615, 0.001));
    });

    testWidgets('notification icon uses textPrimary color', (tester) async {
      await tester.pumpWidget(testApp(const AppHeader(userName: 'Alice')));

      final icon = tester.widget<Icon>(find.byIcon(Icons.notifications_none));
      expect(icon.color, AppSemanticColors.light.textPrimary);
    });
  });
}
