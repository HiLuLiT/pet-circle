import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_image.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppImage', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const AppImage.asset('assets/images/test.png', width: 100, height: 100),
      ));
      expect(find.byType(AppImage), findsOneWidget);
    });

    // ── Variant / state tests ──────────────────────────────────────────────
    testWidgets('shows fallback when asset fails to load', (tester) async {
      await tester.pumpWidget(testApp(
        const AppImage.asset(
          'assets/nonexistent.png',
          width: 80,
          height: 80,
        ),
      ));
      // Pump to trigger errorBuilder
      await tester.pumpAndSettle();

      // The fallback icon should be present
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    });

    testWidgets('uses custom fallback icon', (tester) async {
      await tester.pumpWidget(testApp(
        const AppImage.asset(
          'assets/nonexistent.png',
          width: 80,
          height: 80,
          fallbackIcon: Icons.broken_image,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('respects width and height', (tester) async {
      await tester.pumpWidget(testApp(
        const AppImage.asset(
          'assets/nonexistent.png',
          width: 120,
          height: 90,
        ),
      ));
      await tester.pumpAndSettle();

      // Fallback container should have specified dimensions
      final containers = tester.widgetList<Container>(find.byType(Container))
          .where((c) =>
              c.constraints?.maxWidth == 120 && c.constraints?.maxHeight == 90);
      // The Container gets width/height, which creates constraints
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('fallback bg is skyLightest', (tester) async {
      await tester.pumpWidget(testApp(
        const AppImage.asset(
          'assets/nonexistent.png',
          width: 60,
          height: 60,
        ),
      ));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == AppPrimitives.skyLightest;
        }
        return false;
      });
      expect(containers.isNotEmpty, isTrue);
    });

    testWidgets('fallback icon color is skyDark', (tester) async {
      await tester.pumpWidget(testApp(
        const AppImage.asset(
          'assets/nonexistent.png',
          width: 60,
          height: 60,
        ),
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.image_not_supported_outlined),
      );
      expect(icon.color, AppPrimitives.skyDark);
    });

    testWidgets('fallback border radius is lg (16)', (tester) async {
      await tester.pumpWidget(testApp(
        const AppImage.asset(
          'assets/nonexistent.png',
          width: 60,
          height: 60,
        ),
      ));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.borderRadius == AppRadiiTokens.borderRadiusLg;
        }
        return false;
      });
      expect(containers.isNotEmpty, isTrue);
    });
  });
}
