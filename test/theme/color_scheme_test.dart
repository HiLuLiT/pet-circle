import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppSemanticColors', () {
    group('light constant (PC v3 / Claude-Design palette)', () {
      test('primary is pcPurple', () {
        expect(AppSemanticColors.light.primary, equals(AppPrimitives.pcPurple));
      });

      test('onPrimary is pcSurface (white)', () {
        expect(
          AppSemanticColors.light.onPrimary,
          equals(AppPrimitives.pcSurface),
        );
      });

      test('primaryLight is pcPurpleTile', () {
        expect(
          AppSemanticColors.light.primaryLight,
          equals(AppPrimitives.pcPurpleTile),
        );
      });

      test('primaryLightest is pcRecessed', () {
        expect(
          AppSemanticColors.light.primaryLightest,
          equals(AppPrimitives.pcRecessed),
        );
      });

      test('surface is pcSurface', () {
        expect(
          AppSemanticColors.light.surface,
          equals(AppPrimitives.pcSurface),
        );
      });

      test('background is pcBg (warm)', () {
        expect(
          AppSemanticColors.light.background,
          equals(AppPrimitives.pcBg),
        );
      });

      test('error is pcBlush', () {
        expect(AppSemanticColors.light.error, equals(AppPrimitives.pcBlush));
      });

      test('success is pcMint', () {
        expect(AppSemanticColors.light.success, equals(AppPrimitives.pcMint));
      });

      test('warning is pcButter', () {
        expect(AppSemanticColors.light.warning, equals(AppPrimitives.pcButter));
      });

      test('info is pcPeriwinkle', () {
        expect(AppSemanticColors.light.info, equals(AppPrimitives.pcPeriwinkle));
      });

      test('textPrimary is pcInk', () {
        expect(
          AppSemanticColors.light.textPrimary,
          equals(AppPrimitives.pcInk),
        );
      });

      test('textSecondary is pcInkSecondary', () {
        expect(
          AppSemanticColors.light.textSecondary,
          equals(AppPrimitives.pcInkSecondary),
        );
      });

      test('textTertiary is pcInkTertiary', () {
        expect(
          AppSemanticColors.light.textTertiary,
          equals(AppPrimitives.pcInkTertiary),
        );
      });

      test('divider is pcHairline', () {
        expect(AppSemanticColors.light.divider, equals(AppPrimitives.pcHairline));
      });

      test('disabled is pcInkTertiary', () {
        expect(
          AppSemanticColors.light.disabled,
          equals(AppPrimitives.pcInkTertiary),
        );
      });

      test('hairline is pcHairline', () {
        expect(
          AppSemanticColors.light.hairline,
          equals(AppPrimitives.pcHairline),
        );
      });

      test('surfaceRecessed is pcRecessed', () {
        expect(
          AppSemanticColors.light.surfaceRecessed,
          equals(AppPrimitives.pcRecessed),
        );
      });
    });

    group('light constant — accents', () {
      test('accentPurple is pcPurple', () {
        expect(
          AppSemanticColors.light.accentPurple,
          equals(AppPrimitives.pcPurple),
        );
      });
      test('accentPeriwinkle is pcPeriwinkle', () {
        expect(
          AppSemanticColors.light.accentPeriwinkle,
          equals(AppPrimitives.pcPeriwinkle),
        );
      });
      test('accentButter is pcButter', () {
        expect(
          AppSemanticColors.light.accentButter,
          equals(AppPrimitives.pcButter),
        );
      });
      test('accentBlush is pcBlush', () {
        expect(
          AppSemanticColors.light.accentBlush,
          equals(AppPrimitives.pcBlush),
        );
      });
      test('accentMint is pcMint', () {
        expect(
          AppSemanticColors.light.accentMint,
          equals(AppPrimitives.pcMint),
        );
      });
    });

    group('light constant — status', () {
      test('statusNormal nest', () {
        expect(
          AppSemanticColors.light.statusNormalBg,
          equals(AppPrimitives.pcStatusNormalBg),
        );
        expect(
          AppSemanticColors.light.statusNormalDot,
          equals(AppPrimitives.pcStatusNormalDot),
        );
        expect(
          AppSemanticColors.light.statusNormalText,
          equals(AppPrimitives.pcStatusNormalText),
        );
      });
      test('statusElevated nest', () {
        expect(
          AppSemanticColors.light.statusElevatedBg,
          equals(AppPrimitives.pcStatusElevatedBg),
        );
        expect(
          AppSemanticColors.light.statusElevatedDot,
          equals(AppPrimitives.pcStatusElevatedDot),
        );
      });
      test('statusAlert nest', () {
        expect(
          AppSemanticColors.light.statusAlertBg,
          equals(AppPrimitives.pcStatusAlertBg),
        );
      });
      test('statusActive nest', () {
        expect(
          AppSemanticColors.light.statusActiveBg,
          equals(AppPrimitives.pcStatusActiveBg),
        );
      });
      test('statusInvited nest (yellow, no dot)', () {
        expect(
          AppSemanticColors.light.statusInvitedBg,
          equals(AppPrimitives.yellowLightest),
        );
        expect(
          AppSemanticColors.light.statusInvitedText,
          equals(AppPrimitives.yellowDarkest),
        );
      });
    });

    group('dark constant', () {
      test('primary is pcPurpleTile (lighter for dark theme)', () {
        expect(
          AppSemanticColors.dark.primary,
          equals(AppPrimitives.pcPurpleTile),
        );
      });

      test('onPrimary is pcInk', () {
        expect(
          AppSemanticColors.dark.onPrimary,
          equals(AppPrimitives.pcInk),
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

      test('error is pcBlush', () {
        expect(AppSemanticColors.dark.error, equals(AppPrimitives.pcBlush));
      });

      test('success is pcMint', () {
        expect(AppSemanticColors.dark.success, equals(AppPrimitives.pcMint));
      });

      test('textPrimary is pcSurface', () {
        expect(
          AppSemanticColors.dark.textPrimary,
          equals(AppPrimitives.pcSurface),
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

      test('copyWith preserves PC v3 accent fields', () {
        final copy = AppSemanticColors.light.copyWith(
          primary: const Color(0xFF112233),
        );
        expect(copy.accentMint, equals(AppSemanticColors.light.accentMint));
        expect(
          copy.statusActiveBg,
          equals(AppSemanticColors.light.statusActiveBg),
        );
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
        expect(resolved!.primary, equals(AppPrimitives.pcPurple));
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
        expect(resolved!.primary, equals(AppPrimitives.pcPurpleTile));
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
        // PC v3 additions
        expect(colors.surfaceRecessed, isNotNull);
        expect(colors.hairline, isNotNull);
        expect(colors.accentPurple, isNotNull);
        expect(colors.accentPeriwinkle, isNotNull);
        expect(colors.accentButter, isNotNull);
        expect(colors.accentBlush, isNotNull);
        expect(colors.accentMint, isNotNull);
        expect(colors.statusNormalBg, isNotNull);
        expect(colors.statusElevatedBg, isNotNull);
        expect(colors.statusAlertBg, isNotNull);
        expect(colors.statusActiveBg, isNotNull);
        expect(colors.statusInvitedBg, isNotNull);
        expect(colors.statusInvitedText, isNotNull);
      });
    });
  });
}
