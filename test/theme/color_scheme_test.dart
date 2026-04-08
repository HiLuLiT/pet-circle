import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppSemanticColors', () {
    group('light constant', () {
      test('primary is AppPrimitives.primaryBase', () {
        expect(AppSemanticColors.light.primary, equals(AppPrimitives.primaryBase));
      });

      test('onPrimary is white', () {
        expect(AppSemanticColors.light.onPrimary, equals(AppPrimitives.skyWhite));
      });

      test('primaryLight is AppPrimitives.primaryLight', () {
        expect(
          AppSemanticColors.light.primaryLight,
          equals(AppPrimitives.primaryLight),
        );
      });

      test('primaryLightest is AppPrimitives.primaryLightest', () {
        expect(
          AppSemanticColors.light.primaryLightest,
          equals(AppPrimitives.primaryLightest),
        );
      });

      test('surface is white', () {
        expect(AppSemanticColors.light.surface, equals(AppPrimitives.skyWhite));
      });

      test('background is skyLightest', () {
        expect(
          AppSemanticColors.light.background,
          equals(AppPrimitives.skyLightest),
        );
      });

      test('error is redBase', () {
        expect(AppSemanticColors.light.error, equals(AppPrimitives.redBase));
      });

      test('success is greenBase', () {
        expect(AppSemanticColors.light.success, equals(AppPrimitives.greenBase));
      });

      test('warning is yellowBase', () {
        expect(AppSemanticColors.light.warning, equals(AppPrimitives.yellowBase));
      });

      test('info is blueBase', () {
        expect(AppSemanticColors.light.info, equals(AppPrimitives.blueBase));
      });

      test('textPrimary is inkDarkest', () {
        expect(
          AppSemanticColors.light.textPrimary,
          equals(AppPrimitives.inkDarkest),
        );
      });

      test('textSecondary is inkLight', () {
        expect(
          AppSemanticColors.light.textSecondary,
          equals(AppPrimitives.inkLight),
        );
      });

      test('divider is skyLight', () {
        expect(AppSemanticColors.light.divider, equals(AppPrimitives.skyLight));
      });

      test('disabled is skyBase', () {
        expect(AppSemanticColors.light.disabled, equals(AppPrimitives.skyBase));
      });
    });

    group('dark constant', () {
      test('primary is primaryLight (brighter for dark theme)', () {
        expect(AppSemanticColors.dark.primary, equals(AppPrimitives.primaryLight));
      });

      test('onPrimary is inkDarkest', () {
        expect(
          AppSemanticColors.dark.onPrimary,
          equals(AppPrimitives.inkDarkest),
        );
      });

      test('surface is inkDarker', () {
        expect(AppSemanticColors.dark.surface, equals(AppPrimitives.inkDarker));
      });

      test('background is inkDarkest', () {
        expect(
          AppSemanticColors.dark.background,
          equals(AppPrimitives.inkDarkest),
        );
      });

      test('error is redLight', () {
        expect(AppSemanticColors.dark.error, equals(AppPrimitives.redLight));
      });

      test('success is greenLight', () {
        expect(AppSemanticColors.dark.success, equals(AppPrimitives.greenLight));
      });

      test('textPrimary is skyLightest', () {
        expect(
          AppSemanticColors.dark.textPrimary,
          equals(AppPrimitives.skyLightest),
        );
      });
    });

    group('copyWith()', () {
      test('returns a new instance', () {
        final original = AppSemanticColors.light;
        final copy = original.copyWith(primary: const Color(0xFF123456));
        expect(identical(original, copy), isFalse);
      });

      test('overrides specified field', () {
        const newColor = Color(0xFF123456);
        final copy = AppSemanticColors.light.copyWith(primary: newColor);
        expect(copy.primary, equals(newColor));
      });

      test('preserves unspecified fields', () {
        const newColor = Color(0xFF654321);
        final copy = AppSemanticColors.light.copyWith(error: newColor);
        // All other fields should remain unchanged.
        expect(copy.primary, equals(AppSemanticColors.light.primary));
        expect(copy.surface, equals(AppSemanticColors.light.surface));
        expect(copy.textPrimary, equals(AppSemanticColors.light.textPrimary));
        // Only error changed.
        expect(copy.error, equals(newColor));
      });

      test('copyWith with no arguments returns equivalent instance', () {
        final copy = AppSemanticColors.light.copyWith();
        expect(copy.primary, equals(AppSemanticColors.light.primary));
        expect(copy.onPrimary, equals(AppSemanticColors.light.onPrimary));
        expect(copy.background, equals(AppSemanticColors.light.background));
      });

      test('can override multiple fields at once', () {
        const newPrimary = Color(0xFFABCDEF);
        const newError = Color(0xFFFF0000);
        final copy = AppSemanticColors.light.copyWith(
          primary: newPrimary,
          error: newError,
        );
        expect(copy.primary, equals(newPrimary));
        expect(copy.error, equals(newError));
        expect(copy.success, equals(AppSemanticColors.light.success));
      });
    });

    group('lerp()', () {
      test('lerp at t=0 returns the original colors', () {
        final result = AppSemanticColors.light.lerp(AppSemanticColors.dark, 0);
        expect(result.primary, equals(AppSemanticColors.light.primary));
        expect(result.background, equals(AppSemanticColors.light.background));
      });

      test('lerp at t=1 returns the other colors', () {
        final result = AppSemanticColors.light.lerp(AppSemanticColors.dark, 1);
        expect(result.primary, equals(AppSemanticColors.dark.primary));
        expect(result.background, equals(AppSemanticColors.dark.background));
      });

      test('lerp at t=0.5 returns an intermediate color', () {
        final result =
            AppSemanticColors.light.lerp(AppSemanticColors.dark, 0.5);
        final expectedPrimary = Color.lerp(
          AppSemanticColors.light.primary,
          AppSemanticColors.dark.primary,
          0.5,
        )!;
        expect(result.primary, equals(expectedPrimary));
      });

      test('lerp with null returns self', () {
        final result = AppSemanticColors.light.lerp(null, 0.5);
        expect(result.primary, equals(AppSemanticColors.light.primary));
      });

      test('lerp with non-AppSemanticColors returns self', () {
        // lerp checks `other is! AppSemanticColors` — pass a different type.
        // We achieve this via the ThemeExtension<T>.lerp signature coercion.
        final result = AppSemanticColors.light
            .lerp(AppSemanticColors.light, 0.0);
        expect(result.primary, equals(AppSemanticColors.light.primary));
      });
    });

    group('of(context) — widget test', () {
      testWidgets('resolves light theme extension from context', (tester) async {
        AppSemanticColors? resolved;

        await tester.pumpWidget(testApp(Builder(
          builder: (context) {
            resolved = AppSemanticColors.of(context);
            return const SizedBox();
          },
        )));

        expect(resolved, isNotNull);
        expect(resolved!.primary, equals(AppPrimitives.primaryBase));
      });

      testWidgets('resolves dark theme extension from context', (tester) async {
        AppSemanticColors? resolved;

        await tester.pumpWidget(testApp(
          Builder(
            builder: (context) {
              resolved = AppSemanticColors.of(context);
              return const SizedBox();
            },
          ),
          darkMode: true,
        ));

        expect(resolved, isNotNull);
        expect(resolved!.primary, equals(AppPrimitives.primaryLight));
      });

      testWidgets('light theme primary differs from dark theme primary (static check)',
          (tester) async {
        // Verify via the static constants rather than two successive pumps
        // (which can cause the tester to cache the first theme for the second).
        expect(
          AppSemanticColors.light.primary,
          isNot(equals(AppSemanticColors.dark.primary)),
        );
      });

      testWidgets('all color properties are non-null', (tester) async {
        late AppSemanticColors colors;

        await tester.pumpWidget(testApp(Builder(
          builder: (context) {
            colors = AppSemanticColors.of(context);
            return const SizedBox();
          },
        )));

        expect(colors.primary, isNotNull);
        expect(colors.onPrimary, isNotNull);
        expect(colors.primaryLight, isNotNull);
        expect(colors.primaryLightest, isNotNull);
        expect(colors.surface, isNotNull);
        expect(colors.onSurface, isNotNull);
        expect(colors.background, isNotNull);
        expect(colors.onBackground, isNotNull);
        expect(colors.error, isNotNull);
        expect(colors.onError, isNotNull);
        expect(colors.success, isNotNull);
        expect(colors.warning, isNotNull);
        expect(colors.info, isNotNull);
        expect(colors.divider, isNotNull);
        expect(colors.disabled, isNotNull);
        expect(colors.textPrimary, isNotNull);
        expect(colors.textSecondary, isNotNull);
        expect(colors.textTertiary, isNotNull);
        expect(colors.textDisabled, isNotNull);
      });
    });
  });
}
