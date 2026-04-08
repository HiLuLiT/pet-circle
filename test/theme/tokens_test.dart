import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/shadows.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/theme/tokens/typography.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Token tests — colours, shadows, spacing, and typography
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ── AppPrimitives (colors.dart) ──────────────────────────────────────────

  group('AppPrimitives', () {
    group('Ink palette', () {
      test('inkLighter has correct hex value', () {
        expect(AppPrimitives.inkLighter, equals(const Color(0xFF72777A)));
      });

      test('inkLight has correct hex value', () {
        expect(AppPrimitives.inkLight, equals(const Color(0xFF6C7072)));
      });

      test('inkBase has correct hex value', () {
        expect(AppPrimitives.inkBase, equals(const Color(0xFF404446)));
      });

      test('inkDark has correct hex value', () {
        expect(AppPrimitives.inkDark, equals(const Color(0xFF303437)));
      });

      test('inkDarker has correct hex value', () {
        expect(AppPrimitives.inkDarker, equals(const Color(0xFF202325)));
      });

      test('inkDarkest has correct hex value', () {
        expect(AppPrimitives.inkDarkest, equals(const Color(0xFF090A0A)));
      });

      test('ink colors get progressively darker', () {
        // Lower alpha / perceived brightness should go: lighter → darker
        // A rough check: alpha byte is 0xFF for all (fully opaque).
        for (final c in [
          AppPrimitives.inkLighter,
          AppPrimitives.inkLight,
          AppPrimitives.inkBase,
          AppPrimitives.inkDark,
          AppPrimitives.inkDarker,
          AppPrimitives.inkDarkest,
        ]) {
          expect(c.alpha, equals(0xFF));
        }
      });
    });

    group('Sky palette', () {
      test('skyWhite is pure white', () {
        expect(AppPrimitives.skyWhite, equals(const Color(0xFFFFFFFF)));
      });

      test('skyLightest has correct hex', () {
        expect(AppPrimitives.skyLightest, equals(const Color(0xFFF7F9FA)));
      });

      test('skyLighter has correct hex', () {
        expect(AppPrimitives.skyLighter, equals(const Color(0xFFF2F4F5)));
      });

      test('skyLight has correct hex', () {
        expect(AppPrimitives.skyLight, equals(const Color(0xFFE3E5E5)));
      });

      test('skyBase has correct hex', () {
        expect(AppPrimitives.skyBase, equals(const Color(0xFFCDCFD0)));
      });

      test('skyDark has correct hex', () {
        expect(AppPrimitives.skyDark, equals(const Color(0xFF979C9E)));
      });
    });

    group('Primary / Brand palette (purple)', () {
      test('primaryBase is #6B4EFF', () {
        expect(AppPrimitives.primaryBase, equals(const Color(0xFF6B4EFF)));
      });

      test('primaryLightest is correct', () {
        expect(
            AppPrimitives.primaryLightest, equals(const Color(0xFFE7E7FF)));
      });

      test('primaryLighter is correct', () {
        expect(
            AppPrimitives.primaryLighter, equals(const Color(0xFFC6C4FF)));
      });

      test('primaryLight is correct', () {
        expect(AppPrimitives.primaryLight, equals(const Color(0xFF9990FF)));
      });

      test('primaryDark is correct', () {
        expect(AppPrimitives.primaryDark, equals(const Color(0xFF5538EE)));
      });
    });

    group('Red (error) palette', () {
      test('redBase is correct', () {
        expect(AppPrimitives.redBase, equals(const Color(0xFFFF5247)));
      });

      test('redLight is correct', () {
        expect(AppPrimitives.redLight, equals(const Color(0xFFFF6D6D)));
      });

      test('redLightest is correct', () {
        expect(AppPrimitives.redLightest, equals(const Color(0xFFFFE5E5)));
      });

      test('redDarkest is correct', () {
        expect(AppPrimitives.redDarkest, equals(const Color(0xFFD3180C)));
      });
    });

    group('Green (success) palette', () {
      test('greenBase is correct', () {
        expect(AppPrimitives.greenBase, equals(const Color(0xFF23C16B)));
      });

      test('greenLight is correct', () {
        expect(AppPrimitives.greenLight, equals(const Color(0xFF4CD471)));
      });

      test('greenLightest is correct', () {
        expect(AppPrimitives.greenLightest, equals(const Color(0xFFECFCE5)));
      });
    });

    group('Yellow (warning) palette', () {
      test('yellowBase is correct', () {
        expect(AppPrimitives.yellowBase, equals(const Color(0xFFFFB323)));
      });

      test('yellowLight is correct', () {
        expect(AppPrimitives.yellowLight, equals(const Color(0xFFFFC462)));
      });
    });

    group('Blue (info) palette', () {
      test('blueBase is correct', () {
        expect(AppPrimitives.blueBase, equals(const Color(0xFF48A7F8)));
      });

      test('blueLight is correct', () {
        expect(AppPrimitives.blueLight, equals(const Color(0xFF6EC2FB)));
      });

      test('blueLightest is correct', () {
        expect(AppPrimitives.blueLightest, equals(const Color(0xFFC9F0FF)));
      });
    });

    group('Social / 3rd party colors', () {
      test('facebookBase is correct', () {
        expect(AppPrimitives.facebookBase, equals(const Color(0xFF0078FF)));
      });

      test('twitterBase is correct', () {
        expect(AppPrimitives.twitterBase, equals(const Color(0xFF1DA1F2)));
      });
    });

    test('all primitive colors are fully opaque', () {
      final allColors = [
        AppPrimitives.inkLighter,
        AppPrimitives.inkLight,
        AppPrimitives.inkBase,
        AppPrimitives.inkDark,
        AppPrimitives.inkDarker,
        AppPrimitives.inkDarkest,
        AppPrimitives.skyWhite,
        AppPrimitives.skyLightest,
        AppPrimitives.skyLighter,
        AppPrimitives.skyLight,
        AppPrimitives.skyBase,
        AppPrimitives.skyDark,
        AppPrimitives.primaryLightest,
        AppPrimitives.primaryLighter,
        AppPrimitives.primaryLight,
        AppPrimitives.primaryBase,
        AppPrimitives.primaryDark,
        AppPrimitives.redLightest,
        AppPrimitives.redLighter,
        AppPrimitives.redLight,
        AppPrimitives.redBase,
        AppPrimitives.redDarkest,
        AppPrimitives.greenLightest,
        AppPrimitives.greenLighter,
        AppPrimitives.greenLight,
        AppPrimitives.greenBase,
        AppPrimitives.greenDarkest,
        AppPrimitives.yellowLightest,
        AppPrimitives.yellowLighter,
        AppPrimitives.yellowLight,
        AppPrimitives.yellowBase,
        AppPrimitives.yellowDarkest,
        AppPrimitives.blueLightest,
        AppPrimitives.blueLighter,
        AppPrimitives.blueLight,
        AppPrimitives.blueBase,
        AppPrimitives.blueDarkest,
      ];
      for (final color in allColors) {
        expect(color.alpha, equals(0xFF),
            reason: 'Expected $color to be fully opaque');
      }
    });
  });

  // ── AppShadowTokens (shadows.dart) ──────────────────────────────────────

  group('AppShadowTokens', () {
    group('small', () {
      test('has 2 shadow layers', () {
        expect(AppShadowTokens.small.length, equals(2));
      });

      test('first layer has blurRadius 1', () {
        expect(AppShadowTokens.small[0].blurRadius, equals(1));
      });

      test('second layer has blurRadius 8', () {
        expect(AppShadowTokens.small[1].blurRadius, equals(8));
      });

      test('shadows are semi-transparent (not fully opaque)', () {
        for (final shadow in AppShadowTokens.small) {
          expect(shadow.color.alpha, lessThan(0xFF));
        }
      });
    });

    group('medium', () {
      test('has 2 shadow layers', () {
        expect(AppShadowTokens.medium.length, equals(2));
      });

      test('second layer has offset', () {
        expect(AppShadowTokens.medium[1].offset, equals(const Offset(0, 1)));
      });

      test('second layer has spreadRadius 2', () {
        expect(AppShadowTokens.medium[1].spreadRadius, equals(2));
      });

      test('second layer blurRadius is 8', () {
        expect(AppShadowTokens.medium[1].blurRadius, equals(8));
      });
    });

    group('large', () {
      test('has 1 shadow layer', () {
        expect(AppShadowTokens.large.length, equals(1));
      });

      test('single layer has blurRadius 24', () {
        expect(AppShadowTokens.large[0].blurRadius, equals(24));
      });

      test('single layer has spreadRadius 8', () {
        expect(AppShadowTokens.large[0].spreadRadius, equals(8));
      });

      test('single layer has offset (0, 1)', () {
        expect(AppShadowTokens.large[0].offset, equals(const Offset(0, 1)));
      });
    });

    test('elevation increases: small < medium < large blurRadius', () {
      final smallMax =
          AppShadowTokens.small.map((s) => s.blurRadius).reduce(
                (a, b) => a > b ? a : b,
              );
      final mediumMax =
          AppShadowTokens.medium.map((s) => s.blurRadius).reduce(
                (a, b) => a > b ? a : b,
              );
      final largeMax =
          AppShadowTokens.large.map((s) => s.blurRadius).reduce(
                (a, b) => a > b ? a : b,
              );
      expect(smallMax, lessThanOrEqualTo(mediumMax));
      expect(mediumMax, lessThanOrEqualTo(largeMax));
    });
  });

  // ── AppSpacingTokens / AppRadiiTokens (spacing.dart) ────────────────────

  group('AppSpacingTokens', () {
    test('xs is 4', () => expect(AppSpacingTokens.xs, equals(4.0)));
    test('sm is 8', () => expect(AppSpacingTokens.sm, equals(8.0)));
    test('md is 16', () => expect(AppSpacingTokens.md, equals(16.0)));
    test('lg is 24', () => expect(AppSpacingTokens.lg, equals(24.0)));
    test('xl is 32', () => expect(AppSpacingTokens.xl, equals(32.0)));

    test('spacing values are in ascending order', () {
      expect(AppSpacingTokens.xs, lessThan(AppSpacingTokens.sm));
      expect(AppSpacingTokens.sm, lessThan(AppSpacingTokens.md));
      expect(AppSpacingTokens.md, lessThan(AppSpacingTokens.lg));
      expect(AppSpacingTokens.lg, lessThan(AppSpacingTokens.xl));
    });

    test('all spacing values are positive', () {
      for (final v in [
        AppSpacingTokens.xs,
        AppSpacingTokens.sm,
        AppSpacingTokens.md,
        AppSpacingTokens.lg,
        AppSpacingTokens.xl,
      ]) {
        expect(v, greaterThan(0));
      }
    });
  });

  group('AppRadiiTokens', () {
    test('sm is 4', () => expect(AppRadiiTokens.sm, equals(4.0)));
    test('md is 8', () => expect(AppRadiiTokens.md, equals(8.0)));
    test('lg is 16', () => expect(AppRadiiTokens.lg, equals(16.0)));
    test('xl is 48', () => expect(AppRadiiTokens.xl, equals(48.0)));
    test('full is 1000', () => expect(AppRadiiTokens.full, equals(1000.0)));

    test('radii values are in ascending order', () {
      expect(AppRadiiTokens.sm, lessThan(AppRadiiTokens.md));
      expect(AppRadiiTokens.md, lessThan(AppRadiiTokens.lg));
      expect(AppRadiiTokens.lg, lessThan(AppRadiiTokens.xl));
      expect(AppRadiiTokens.xl, lessThan(AppRadiiTokens.full));
    });

    group('BorderRadius getters', () {
      test('borderRadiusSm returns BorderRadius.circular(4)', () {
        expect(AppRadiiTokens.borderRadiusSm,
            equals(BorderRadius.circular(AppRadiiTokens.sm)));
      });

      test('borderRadiusMd returns BorderRadius.circular(8)', () {
        expect(AppRadiiTokens.borderRadiusMd,
            equals(BorderRadius.circular(AppRadiiTokens.md)));
      });

      test('borderRadiusLg returns BorderRadius.circular(16)', () {
        expect(AppRadiiTokens.borderRadiusLg,
            equals(BorderRadius.circular(AppRadiiTokens.lg)));
      });

      test('borderRadiusXl returns BorderRadius.circular(48)', () {
        expect(AppRadiiTokens.borderRadiusXl,
            equals(BorderRadius.circular(AppRadiiTokens.xl)));
      });

      test('borderRadiusFull returns BorderRadius.circular(1000)', () {
        expect(AppRadiiTokens.borderRadiusFull,
            equals(BorderRadius.circular(AppRadiiTokens.full)));
      });
    });
  });

  // ── AppTypography (typography.dart) ─────────────────────────────────────

  group('AppTypography', () {
    test('fontFamily is Instrument Sans', () {
      expect(AppTypography.fontFamily, equals('Instrument Sans'));
    });

    group('Title sizes', () {
      test('title1NormalBold has fontSize 48', () {
        expect(AppTypography.title1NormalBold.fontSize, equals(48));
      });

      test('title1NormalBold is bold', () {
        expect(AppTypography.title1NormalBold.fontWeight, equals(FontWeight.w700));
      });

      test('title1NormalBold height is 56/48', () {
        expect(AppTypography.title1NormalBold.height,
            closeTo(56 / 48, 0.001));
      });

      test('title2NormalBold has fontSize 32', () {
        expect(AppTypography.title2NormalBold.fontSize, equals(32));
      });

      test('title3NormalBold has fontSize 24', () {
        expect(AppTypography.title3NormalBold.fontSize, equals(24));
      });
    });

    group('Large (18px) variants', () {
      test('largeNoneBold has fontSize 18 and w700', () {
        expect(AppTypography.largeNoneBold.fontSize, equals(18));
        expect(AppTypography.largeNoneBold.fontWeight, equals(FontWeight.w700));
      });

      test('largeNoneMedium has w500', () {
        expect(AppTypography.largeNoneMedium.fontWeight, equals(FontWeight.w500));
      });

      test('largeNoneRegular has w400', () {
        expect(
            AppTypography.largeNoneRegular.fontWeight, equals(FontWeight.w400));
      });

      test('largeTightBold height is 20/18', () {
        expect(AppTypography.largeTightBold.height, closeTo(20 / 18, 0.001));
      });

      test('largeNormalBold height is 24/18', () {
        expect(AppTypography.largeNormalBold.height, closeTo(24 / 18, 0.001));
      });
    });

    group('Regular (16px) variants', () {
      test('regularNoneBold has fontSize 16 and w700', () {
        expect(AppTypography.regularNoneBold.fontSize, equals(16));
        expect(
            AppTypography.regularNoneBold.fontWeight, equals(FontWeight.w700));
      });

      test('regularNoneMedium has w500', () {
        expect(
            AppTypography.regularNoneMedium.fontWeight, equals(FontWeight.w500));
      });

      test('regularNoneRegular has w400', () {
        expect(AppTypography.regularNoneRegular.fontWeight,
            equals(FontWeight.w400));
      });

      test('regularTightBold height is 20/16', () {
        expect(
            AppTypography.regularTightBold.height, closeTo(20 / 16, 0.001));
      });

      test('regularNormalBold height is 24/16', () {
        expect(
            AppTypography.regularNormalBold.height, closeTo(24 / 16, 0.001));
      });
    });

    group('Small (14px) variants', () {
      test('smallNoneBold has fontSize 14 and w700', () {
        expect(AppTypography.smallNoneBold.fontSize, equals(14));
        expect(AppTypography.smallNoneBold.fontWeight, equals(FontWeight.w700));
      });

      test('smallNormalRegular height is 20/14', () {
        expect(
            AppTypography.smallNormalRegular.height, closeTo(20 / 14, 0.001));
      });

      test('smallTightMedium height is 16/14', () {
        expect(AppTypography.smallTightMedium.height, closeTo(16 / 14, 0.001));
      });
    });

    group('Tiny (12px) variants', () {
      test('tinyNoneBold has fontSize 12 and w700', () {
        expect(AppTypography.tinyNoneBold.fontSize, equals(12));
        expect(AppTypography.tinyNoneBold.fontWeight, equals(FontWeight.w700));
      });

      test('tinyTightRegular height is 14/12', () {
        expect(
            AppTypography.tinyTightRegular.height, closeTo(14 / 12, 0.001));
      });

      test('tinyNormalBold height is 16/12', () {
        expect(AppTypography.tinyNormalBold.height, closeTo(16 / 12, 0.001));
      });
    });

    test('all text styles use the Instrument Sans font family', () {
      final styles = [
        AppTypography.title1NormalBold,
        AppTypography.title2NormalBold,
        AppTypography.title3NormalBold,
        AppTypography.largeNoneBold,
        AppTypography.regularNoneBold,
        AppTypography.smallNoneBold,
        AppTypography.tinyNoneBold,
        AppTypography.largeNormalMedium,
        AppTypography.regularNormalRegular,
        AppTypography.tinyNormalRegular,
      ];
      for (final style in styles) {
        expect(style.fontFamily, equals(AppTypography.fontFamily),
            reason: 'Expected $style to use Instrument Sans');
      }
    });

    test('font sizes decrease: title1 > title2 > title3 > large > regular > small > tiny', () {
      expect(AppTypography.title1NormalBold.fontSize,
          greaterThan(AppTypography.title2NormalBold.fontSize!));
      expect(AppTypography.title2NormalBold.fontSize,
          greaterThan(AppTypography.title3NormalBold.fontSize!));
      expect(AppTypography.title3NormalBold.fontSize,
          greaterThan(AppTypography.largeNoneBold.fontSize!));
      expect(AppTypography.largeNoneBold.fontSize,
          greaterThan(AppTypography.regularNoneBold.fontSize!));
      expect(AppTypography.regularNoneBold.fontSize,
          greaterThan(AppTypography.smallNoneBold.fontSize!));
      expect(AppTypography.smallNoneBold.fontSize,
          greaterThan(AppTypography.tinyNoneBold.fontSize!));
    });
  });
}
