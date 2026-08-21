import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/theme/tokens/typography.dart';

/// Parity guard between the Figma Design System and the Dart token layer.
///
/// Source of truth: Figma DS node `402-1191`
/// https://www.figma.com/design/ApTk87wJXejOTzVtEnFJMw/Pet-circle?node-id=402-1191
///
/// Every expectation below is transcribed verbatim from `get_variable_defs` on
/// that node. When the DS changes, update the tables here **first**, watch this
/// test fail, then change the tokens — that way a token can never silently
/// drift away from the design while keeping a plausible-looking name.
///
/// This exists because drift is invisible by inspection: `pcStatusActiveBg` was
/// named correctly for the "Active" pill but held `#D7EECB` where the DS says
/// `#C2E8C8`, and nothing caught it until a screen was diffed by hand.
///
/// ## Letter spacing is a PERCENT
///
/// Figma reports type-style letter spacing as a percentage of the font size,
/// with no unit marker — `get_variable_defs` shows `Display/M ... letterSpacing:
/// -0.5`, which the rendered node resolves to `-0.14px` at 28px. Flutter's
/// [TextStyle.letterSpacing] is in logical pixels, so the DS number must be
/// converted: `px = fontSize * percent / 100`. Verified against two independent
/// rendered instances (20px -> -0.04px, 28px -> -0.14px). [_FigmaType] does the
/// conversion so the tables can hold the raw DS percentages.
void main() {
  group('Figma DS parity — colors (node 402-1191)', () {
    // Figma name -> (hex from the DS, Dart primitive).
    final colors = <String, (int, Color)>{
      'Neutrals/Ink': (0xFF161616, AppPrimitives.pcInk),
      'Neutrals/Secondary': (0xFF595959, AppPrimitives.pcInkSecondary),
      'Neutrals/Tertiary': (0xFF9A9A9A, AppPrimitives.pcInkTertiary),
      'Neutrals/Background': (0xFFF5F3EF, AppPrimitives.pcBg),
      'Neutrals/White': (0xFFFFFFFF, AppPrimitives.pcSurface),
      'Candy/Purple/Accent': (0xFF7E5CE0, AppPrimitives.pcPurple),
      'Candy/Purple/Tile': (0xFFC3AEF0, AppPrimitives.pcPurpleTile),
      'Candy/Purple/Ghost': (0xFFE7E7FF, AppPrimitives.pcPurpleGhost),
      'Candy/Mint/Accent': (0xFF46A05F, AppPrimitives.pcMint),
      'Candy/Mint/Tile': (0xFFC2E8C8, AppPrimitives.pcMintTile),
      'Candy/Periwinkle/Accent': (0xFF6485DB, AppPrimitives.pcPeriwinkle),
      'Candy/Periwinkle/Tile': (0xFFD2DCF5, AppPrimitives.pcPeriwinkleTile),
      'Candy/Blush/Accent': (0xFFDD6593, AppPrimitives.pcBlush),
      'Candy/Blush/Tile': (0xFFFCE4EC, AppPrimitives.pcBlushTile),
      'Candy/Butter/Cream': (0xFFE8E4D8, AppPrimitives.pcButterCream),
    };

    colors.forEach((figmaName, pair) {
      final (hex, token) = pair;
      test('$figmaName == ${_hex(hex)}', () {
        expect(
          token.toARGB32(),
          hex,
          reason:
              '$figmaName is ${_hex(hex)} in Figma DS 402-1191 but the token '
              'resolves to ${_hex(token.toARGB32())}.',
        );
      });
    });
  });

  group('Figma DS parity — status pills', () {
    // The DS "Pills" component draws Active from the Candy/Mint family.
    // Regression guard for the #D7EECB / #2F6B3E drift found on 2026-08-21.
    test('Active pill uses Candy/Mint tile + accent', () {
      expect(AppPrimitives.pcStatusActiveBg, AppPrimitives.pcMintTile);
      expect(AppPrimitives.pcStatusActiveText, AppPrimitives.pcMint);
    });
  });

  group('Figma DS parity — spacing', () {
    // Measured across Figma nodes 442:6747, 407:3528, 442:8893, 442:8959 and
    // 426:1182. The old pc* scale (6/10/14/18/24) covered only 24 of these.
    test('every spacing value used in Figma has a token', () {
      const figmaSteps = <double>[4, 8, 12, 16, 20, 24, 28, 32];
      const scale = <double>[
        AppSpacingTokens.pcXs,
        AppSpacingTokens.pcSm,
        AppSpacingTokens.pcMd,
        AppSpacingTokens.pcLg,
        AppSpacingTokens.pcXl,
        AppSpacingTokens.pc2Xl,
        AppSpacingTokens.pc20,
        AppSpacingTokens.pc28,
      ];
      for (final step in figmaSteps) {
        expect(
          scale,
          contains(step),
          reason:
              '${step}px is used in the Figma home nodes but no spacing '
              'token resolves to it.',
        );
      }
    });

    test('core scale is the Figma rhythm', () {
      expect(AppSpacingTokens.pcXs, 4);
      expect(AppSpacingTokens.pcSm, 8);
      expect(AppSpacingTokens.pcMd, 12);
      expect(AppSpacingTokens.pcLg, 16);
      expect(AppSpacingTokens.pcXl, 24);
      expect(AppSpacingTokens.pc2Xl, 32);
    });

    test('legacy names alias onto the Figma-aligned scale', () {
      expect(AppSpacingTokens.xs, AppSpacingTokens.pcXs);
      expect(AppSpacingTokens.sm, AppSpacingTokens.pcSm);
      expect(AppSpacingTokens.md, AppSpacingTokens.pcLg);
      expect(AppSpacingTokens.lg, AppSpacingTokens.pcXl);
      expect(AppSpacingTokens.xl, AppSpacingTokens.pc2Xl);
    });
  });

  group('Figma DS parity — radii', () {
    test('field / card / pill radii match Figma', () {
      expect(AppRadiiTokens.pcField, 12);
      expect(AppRadiiTokens.pcCard, 16);
      expect(AppRadiiTokens.pcPill, greaterThanOrEqualTo(999));
    });
  });

  group('Figma DS parity — type scale (node 402-1191)', () {
    // Figma name -> (DS spec, Dart token). letterSpacing values are the raw
    // Figma PERCENTAGES; _FigmaType converts them to logical px.
    final types = <String, (_FigmaType, TextStyle)>{
      'Display/XXL': (
        _FigmaType(56, FontWeight.w700, 64),
        AppTypography.pcDisplayXxlBold,
      ),
      'Display/XL': (
        _FigmaType(40, FontWeight.w700, 48),
        AppTypography.pcDisplayXlBold,
      ),
      'Display/L': (
        _FigmaType(36, FontWeight.w700, 44),
        AppTypography.pcDisplayLBold,
      ),
      'Display/M': (
        _FigmaType(28, FontWeight.w700, 36, pct: -0.5),
        AppTypography.pcDisplayMBold,
      ),
      'Heading/H1': (
        _FigmaType(24, FontWeight.w700, 32, pct: -0.3),
        AppTypography.pcHeadingH1Bold,
      ),
      'Heading/H2': (
        _FigmaType(20, FontWeight.w700, 28, pct: -0.2),
        AppTypography.pcHeadingH2Bold,
      ),
      'Heading/XS': (
        _FigmaType(16, FontWeight.w700, 22),
        AppTypography.pcHeadingXsBold,
      ),
      'Body/SemiBold': (
        _FigmaType(16, FontWeight.w600, 24),
        AppTypography.pcBodySemibold,
      ),
      'Body/Medium': (
        _FigmaType(16, FontWeight.w500, 24),
        AppTypography.pcBodyMedium,
      ),
      'Body/Regular': (
        _FigmaType(16, FontWeight.w400, 24),
        AppTypography.pcBodyRegular,
      ),
      'Label/M SemiBold': (
        _FigmaType(14, FontWeight.w600, 20),
        AppTypography.pcLabelSemibold,
      ),
      'Label/M Regular': (
        _FigmaType(14, FontWeight.w400, 20),
        AppTypography.pcLabelRegular,
      ),
      'Label/S SemiBold': (
        _FigmaType(13, FontWeight.w600, 18),
        AppTypography.pcLabelSSemibold,
      ),
      'Label/S Regular': (
        _FigmaType(13, FontWeight.w400, 18),
        AppTypography.pcLabelSRegular,
      ),
      'Caption/XS': (
        _FigmaType(10, FontWeight.w700, 14),
        AppTypography.pcCaptionXsBold,
      ),
    };

    types.forEach((figmaName, pair) {
      final (spec, token) = pair;
      test('$figmaName matches the DS spec', () {
        expect(token.fontFamily, AppTypography.fontFamily, reason: figmaName);
        expect(token.fontSize, spec.size, reason: '$figmaName font size');
        expect(token.fontWeight, spec.weight, reason: '$figmaName weight');
        expect(
          token.height! * spec.size,
          closeTo(spec.lineHeight, 0.01),
          reason:
              '$figmaName line height should be ${spec.lineHeight}px '
              'at ${spec.size}px',
        );
        expect(
          token.letterSpacing ?? 0,
          closeTo(spec.letterSpacingPx, 0.0005),
          reason:
              '$figmaName: Figma says ${spec.pct}% of ${spec.size}px = '
              '${spec.letterSpacingPx}px. Figma letter spacing is a PERCENT, '
              'not logical pixels.',
        );
      });
    });
  });
}

/// A type style as the Figma DS states it — with letter spacing as the raw
/// Figma percentage, converted to logical px on demand.
class _FigmaType {
  const _FigmaType(this.size, this.weight, this.lineHeight, {this.pct = 0});

  final double size;
  final FontWeight weight;
  final double lineHeight;

  /// Letter spacing as Figma reports it: a percentage of [size].
  final double pct;

  /// Flutter's `letterSpacing`, in logical pixels.
  double get letterSpacingPx => size * pct / 100;
}

String _hex(int argb) =>
    '#${argb.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';
