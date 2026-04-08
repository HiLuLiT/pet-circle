import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';

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

    test('scaffold background color is white', () {
      expect(theme.scaffoldBackgroundColor, equals(AppPrimitives.skyWhite));
    });

    test('primary color is primaryBase', () {
      expect(theme.colorScheme.primary, equals(AppPrimitives.primaryBase));
    });

    test('color scheme surface is white', () {
      expect(theme.colorScheme.surface, equals(AppPrimitives.skyWhite));
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
        expect(
          theme.textTheme.bodyMedium?.fontWeight,
          equals(FontWeight.w400),
        );
      });

      test('labelSmall has fontSize 12', () {
        expect(theme.textTheme.labelSmall?.fontSize, equals(12));
      });
    });

    group('inputDecorationTheme', () {
      test('inputs are filled', () {
        expect(theme.inputDecorationTheme.filled, isTrue);
      });

      test('fill color is skyLighter', () {
        expect(
          theme.inputDecorationTheme.fillColor,
          equals(AppPrimitives.skyLighter),
        );
      });

      test('border is OutlineInputBorder', () {
        expect(
          theme.inputDecorationTheme.border,
          isA<OutlineInputBorder>(),
        );
      });

      test('border has borderRadius of 16', () {
        final border =
            theme.inputDecorationTheme.border as OutlineInputBorder;
        expect(border.borderRadius, equals(BorderRadius.circular(16)));
      });

      test('border side is none', () {
        final border =
            theme.inputDecorationTheme.border as OutlineInputBorder;
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
      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFF1A1A1A)));
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

      test('fill color is dark', () {
        expect(
          theme.inputDecorationTheme.fillColor,
          equals(const Color(0xFF2A2420)),
        );
      });

      test('border is OutlineInputBorder with radius 16', () {
        final border =
            theme.inputDecorationTheme.border as OutlineInputBorder;
        expect(border.borderRadius, equals(BorderRadius.circular(16)));
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
              expect(colors.primary, equals(AppPrimitives.primaryBase));
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
              expect(colors.primary, equals(AppPrimitives.primaryLight));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
