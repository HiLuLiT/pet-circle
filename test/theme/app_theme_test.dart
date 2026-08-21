import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

void main() {
  group('buildAppTheme()', () {
    late ThemeData theme;

    setUpAll(() {
      theme = buildAppTheme();
    });

    test('returns a ThemeData instance', () {
      expect(theme, isA<ThemeData>());
    });

    test('brightness is light', () {
      expect(theme.brightness, equals(Brightness.light));
    });

    test('scaffold background color is pcBg (warm)', () {
      expect(theme.scaffoldBackgroundColor, equals(AppPrimitives.pcBg));
    });

    test('primary color is pcPurple', () {
      expect(theme.colorScheme.primary, equals(AppPrimitives.pcPurple));
    });

    test('color scheme surface is pcSurface', () {
      expect(theme.colorScheme.surface, equals(AppPrimitives.pcSurface));
    });

    test('contains AppSemanticColors extension', () {
      final ext = theme.extension<AppSemanticColors>();
      expect(ext, isNotNull);
    });

    test('AppSemanticColors extension matches light constants', () {
      final ext = theme.extension<AppSemanticColors>()!;
      expect(ext.primary, equals(AppSemanticColors.light.primary));
      expect(ext.background, equals(AppSemanticColors.light.background));
    });

    group('textTheme', () {
      test('headlineSmall has fontSize 24', () {
        expect(theme.textTheme.headlineSmall?.fontSize, equals(24));
      });

      test('headlineSmall is bold (w700)', () {
        expect(
          theme.textTheme.headlineSmall?.fontWeight,
          equals(FontWeight.w700),
        );
      });

      test('titleLarge has fontSize 18', () {
        expect(theme.textTheme.titleLarge?.fontSize, equals(18));
      });

      test('bodyMedium has fontSize 16', () {
        expect(theme.textTheme.bodyMedium?.fontSize, equals(16));
      });

      test('bodyMedium is regular weight (w400)', () {
        expect(theme.textTheme.bodyMedium?.fontWeight, equals(FontWeight.w400));
      });

      test('labelSmall has fontSize 12', () {
        expect(theme.textTheme.labelSmall?.fontSize, equals(12));
      });
    });

    group('inputDecorationTheme', () {
      test('inputs are filled', () {
        expect(theme.inputDecorationTheme.filled, isTrue);
      });

      test('fill color is pcRecessed', () {
        expect(
          theme.inputDecorationTheme.fillColor,
          equals(AppPrimitives.pcRecessed),
        );
      });

      test('border is OutlineInputBorder', () {
        expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
      });

      test('border uses the DS field radius (12)', () {
        final border = theme.inputDecorationTheme.border as OutlineInputBorder;
        expect(border.borderRadius, equals(AppRadiiTokens.borderRadiusField));
      });

      test('border side is none', () {
        final border = theme.inputDecorationTheme.border as OutlineInputBorder;
        expect(border.borderSide, equals(BorderSide.none));
      });
    });
  });

  group('buildDarkTheme()', () {
    late ThemeData theme;

    setUpAll(() {
      theme = buildDarkTheme();
    });

    test('returns a ThemeData instance', () {
      expect(theme, isA<ThemeData>());
    });

    test('brightness is dark', () {
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('scaffold background is dark', () {
      expect(theme.scaffoldBackgroundColor, equals(AppPrimitives.pcDarkCanvas));
    });

    test('contains AppSemanticColors extension', () {
      final ext = theme.extension<AppSemanticColors>();
      expect(ext, isNotNull);
    });

    test('AppSemanticColors extension matches dark constants', () {
      final ext = theme.extension<AppSemanticColors>()!;
      expect(ext.primary, equals(AppSemanticColors.dark.primary));
      expect(ext.background, equals(AppSemanticColors.dark.background));
    });

    group('textTheme', () {
      test('headlineSmall has fontSize 24', () {
        expect(theme.textTheme.headlineSmall?.fontSize, equals(24));
      });

      test('headlineSmall is bold (w700)', () {
        expect(
          theme.textTheme.headlineSmall?.fontWeight,
          equals(FontWeight.w700),
        );
      });

      test('bodyMedium has fontSize 16', () {
        expect(theme.textTheme.bodyMedium?.fontSize, equals(16));
      });

      test('labelSmall has fontSize 12', () {
        expect(theme.textTheme.labelSmall?.fontSize, equals(12));
      });
    });

    group('inputDecorationTheme', () {
      test('inputs are filled', () {
        expect(theme.inputDecorationTheme.filled, isTrue);
      });

      test('fill color is the well, one step below the card surface', () {
        expect(
          theme.inputDecorationTheme.fillColor,
          equals(AppPrimitives.pcDarkWell),
        );
        // An input is recessed, so it must be darker than the card it sits on.
        expect(
          AppPrimitives.pcDarkWell.computeLuminance(),
          lessThan(AppPrimitives.pcDarkSurface.computeLuminance()),
        );
      });

      test('border is OutlineInputBorder at the DS field radius (12)', () {
        final border = theme.inputDecorationTheme.border as OutlineInputBorder;
        expect(border.borderRadius, equals(AppRadiiTokens.borderRadiusField));
      });
    });
  });

  group('light vs dark theme differences', () {
    late ThemeData light;
    late ThemeData dark;

    setUpAll(() {
      light = buildAppTheme();
      dark = buildDarkTheme();
    });

    test('light and dark have different brightness values', () {
      expect(light.brightness, isNot(equals(dark.brightness)));
    });

    test('dark textTheme paints the pcDark ink ramp', () {
      final t = buildDarkTheme().textTheme;
      expect(t.headlineSmall?.color, AppPrimitives.pcDarkInk);
      expect(t.titleLarge?.color, AppPrimitives.pcDarkInk);
      expect(t.bodyMedium?.color, AppPrimitives.pcDarkInk);
      expect(t.bodySmall?.color, AppPrimitives.pcDarkInkSecondary);
      expect(t.labelSmall?.color, AppPrimitives.pcDarkInkSecondary);
    });

    test('buildDarkTheme wires the slots that used to be unset', () {
      // Left at ThemeData defaults before, so any stock Material widget
      // reading them rendered from M3's generated tonal palette instead.
      final t = buildDarkTheme();
      expect(t.dividerColor, AppSemanticColors.dark.divider);
      expect(t.cardColor, AppSemanticColors.dark.surface);
      expect(t.canvasColor, AppSemanticColors.dark.background);
      expect(t.appBarTheme.backgroundColor, AppPrimitives.pcDarkCanvas);
      expect(t.appBarTheme.foregroundColor, AppPrimitives.pcDarkInk);
      expect(t.iconTheme.color, AppPrimitives.pcDarkInkSecondary);
      // Dialogs and sheets float one step up the ladder from a card.
      expect(t.dialogTheme.backgroundColor, AppPrimitives.pcDarkElevated);
      expect(t.bottomSheetTheme.backgroundColor, AppPrimitives.pcDarkElevated);
      expect(t.snackBarTheme.backgroundColor, AppPrimitives.pcDarkElevated);
    });

    test('dark ColorScheme is authored, not seeded from the brand purple', () {
      // fromSeed left ~20 slots to M3's tonal generator, which produced cool
      // violet-tinted greys that fought the warm palette.
      final cs = buildDarkTheme().colorScheme;
      expect(cs.surface, AppPrimitives.pcDarkSurface);
      expect(cs.onSurface, AppPrimitives.pcDarkInk);
      expect(cs.onSurfaceVariant, AppPrimitives.pcDarkInkSecondary);
      expect(cs.surfaceContainerLowest, AppPrimitives.pcDarkCanvas);
      expect(cs.surfaceContainerLow, AppPrimitives.pcDarkWell);
      expect(cs.surfaceContainerHigh, AppPrimitives.pcDarkElevated);
      expect(cs.outline, AppPrimitives.pcDarkDivider);
      expect(cs.outlineVariant, AppPrimitives.pcDarkHairline);
    });

    test('the two dark palettes agree (they used to be disjoint)', () {
      // The whole root cause: buildDarkTheme() painted from pcDark* while
      // widgets read AppSemanticColors.dark, built from legacy v2 greys.
      final t = buildDarkTheme();
      final c = t.extension<AppSemanticColors>()!;
      expect(t.scaffoldBackgroundColor, c.background);
      expect(t.colorScheme.surface, c.surface);
      expect(t.colorScheme.primary, c.primary);
      expect(t.textTheme.bodyMedium?.color, c.textPrimary);
      expect(t.inputDecorationTheme.fillColor, c.surfaceRecessed);
    });

    test('light and dark have different scaffold background colors', () {
      expect(
        light.scaffoldBackgroundColor,
        isNot(equals(dark.scaffoldBackgroundColor)),
      );
    });

    test('light and dark semantic extensions differ on primary', () {
      final lightExt = light.extension<AppSemanticColors>()!;
      final darkExt = dark.extension<AppSemanticColors>()!;
      expect(lightExt.primary, isNot(equals(darkExt.primary)));
    });

    test('light and dark semantic extensions differ on background', () {
      final lightExt = light.extension<AppSemanticColors>()!;
      final darkExt = dark.extension<AppSemanticColors>()!;
      expect(lightExt.background, isNot(equals(darkExt.background)));
    });

    test('both themes expose the same textTheme font sizes', () {
      // Font sizes are the same in both themes; only colors differ.
      expect(
        light.textTheme.headlineSmall?.fontSize,
        equals(dark.textTheme.headlineSmall?.fontSize),
      );
      expect(
        light.textTheme.bodyMedium?.fontSize,
        equals(dark.textTheme.bodyMedium?.fontSize),
      );
    });
  });

  group('testApp integration — theme resolves in widget tree', () {
    testWidgets('buildAppTheme() integrates with MaterialApp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) {
              final colors = AppSemanticColors.of(context);
              expect(colors.primary, equals(AppPrimitives.pcPurple));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('buildDarkTheme() integrates with MaterialApp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(),
          home: Builder(
            builder: (context) {
              final colors = AppSemanticColors.of(context);
              expect(colors.primary, equals(AppPrimitives.pcDarkPurple));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
