import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';

/// Contrast + structure assertions for the dark palette.
///
/// The previous dark theme was not failing WCAG — it was failing *upward*.
/// #FFFFFF on #090A0A is 19.82:1, near the 21:1 sRGB maximum, and that is what
/// made it feel harsh. So these tests assert a **ceiling as well as a floor**:
/// a regression toward pure white on near-black must fail here, not merely be
/// noticed by eye later.
///
/// Adjacent dark surfaces are checked in CIE L\* rather than contrast ratio.
/// Ratio is the wrong instrument down there — the old surface/background pair
/// scored 1.25:1 whether or not you could actually see the card edge.
void main() {
  const light = AppSemanticColors.light;
  const dark = AppSemanticColors.dark;

  const canvas = AppPrimitives.pcDarkCanvas;
  const well = AppPrimitives.pcDarkWell;
  const surface = AppPrimitives.pcDarkSurface;
  const elevated = AppPrimitives.pcDarkElevated;

  /// WCAG 2.x relative luminance. Flutter's [Color.computeLuminance] already
  /// implements this, so it is used directly rather than reimplemented.
  double lum(Color c) => c.computeLuminance();

  /// WCAG 2.x contrast ratio, (L1 + 0.05) / (L2 + 0.05).
  double ratio(Color a, Color b) {
    final la = lum(a);
    final lb = lum(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// CIE L\* (0-100) from relative luminance — perceptual lightness, which is
  /// what actually predicts whether two dark surfaces look separated.
  double lStar(Color c) {
    final y = lum(c);
    return y > 0.008856 ? 116 * math.pow(y, 1 / 3) - 16 : 903.3 * y;
  }

  void expectAtLeast(Color fg, Color bg, double floor, String what) {
    final r = ratio(fg, bg);
    expect(
      r,
      greaterThanOrEqualTo(floor),
      reason:
          '$what: ${r.toStringAsFixed(2)}:1 is below the $floor:1 floor '
          '(fg $fg on bg $bg)',
    );
  }

  group('dark text on every surface in the ladder', () {
    // Any of these can host body text, so each pairing has to clear AA.
    const surfaces = {
      'canvas': canvas,
      'well': well,
      'surface': surface,
      'elevated': elevated,
    };

    for (final entry in surfaces.entries) {
      test('textPrimary clears AAA on ${entry.key}', () {
        expectAtLeast(dark.textPrimary, entry.value, 7.0, 'textPrimary');
      });

      test('textSecondary clears AA on ${entry.key}', () {
        expectAtLeast(dark.textSecondary, entry.value, 4.5, 'textSecondary');
      });

      // The binding constraint for textTertiary. #8D877C was the original
      // candidate and reaches only 4.13:1 here, which is what moved it.
      test('textTertiary clears AA on ${entry.key}', () {
        expectAtLeast(dark.textTertiary, entry.value, 4.5, 'textTertiary');
      });
    }
  });

  group('the harshness ceiling', () {
    test('textPrimary on the canvas sits in the 14-16.5:1 band', () {
      final r = ratio(dark.textPrimary, dark.background);
      expect(
        r,
        greaterThanOrEqualTo(14.0),
        reason: 'body text must still be comfortably AAA, got $r',
      );
      // The load-bearing assertion of this file. Material 3 (#E6E0E9 on
      // #141218), Primer (#e6edf3 on #0d1117) and Carbon g100 (#f4f4f4 on
      // #161616) all land in this band; the old palette sat at 19.82:1.
      expect(
        r,
        lessThanOrEqualTo(16.5),
        reason:
            'textPrimary is ${r.toStringAsFixed(2)}:1 — drifting back toward '
            'the 21:1 maximum is what made the old dark theme feel hard',
      );
    });

    test('textPrimary is not pure white', () {
      expect(dark.textPrimary, isNot(equals(const Color(0xFFFFFFFF))));
    });

    test('background is not pure black', () {
      expect(dark.background, isNot(equals(const Color(0xFF000000))));
    });
  });

  group('text ramp is monotonic', () {
    // The old dark constant had textSecondary (#979C9E) DARKER than
    // textTertiary (#CDCFD0), inverting the type hierarchy.
    test('primary > secondary > tertiary > disabled by luminance', () {
      expect(lum(dark.textPrimary), greaterThan(lum(dark.textSecondary)));
      expect(lum(dark.textSecondary), greaterThan(lum(dark.textTertiary)));
      expect(lum(dark.textTertiary), greaterThan(lum(dark.textDisabled)));
    });

    test('light ramp is monotonic too (darker as it recedes)', () {
      expect(lum(light.textPrimary), lessThan(lum(light.textSecondary)));
      expect(
        lum(light.textSecondary),
        lessThanOrEqualTo(lum(light.textTertiary)),
      );
    });
  });

  group('surface ladder', () {
    test('canvas < well < surface < elevated by luminance', () {
      expect(lum(canvas), lessThan(lum(well)));
      expect(lum(well), lessThan(lum(surface)));
      expect(lum(surface), lessThan(lum(elevated)));
    });

    test('each step is a visible L* move, but not a jump', () {
      // M3's own dark tonal sequence steps roughly +2 to +5 tone per level.
      final steps = <String, double>{
        'canvas->well': lStar(well) - lStar(canvas),
        'well->surface': lStar(surface) - lStar(well),
        'surface->elevated': lStar(elevated) - lStar(surface),
      };
      for (final s in steps.entries) {
        expect(
          s.value,
          inInclusiveRange(2.0, 6.0),
          reason: '${s.key} moves ${s.value.toStringAsFixed(2)} L*',
        );
      }
    });

    test('recessed is darker than surface, not lighter', () {
      // The old constant had surfaceRecessed (#303437) LIGHTER than surface
      // (#202325), so "recessed" read as raised.
      expect(lum(dark.surfaceRecessed), lessThan(lum(dark.surface)));
      expect(lum(light.surfaceRecessed), lessThan(lum(light.surface)));
    });

    test(
      'divider and hairline are visible against the surfaces they sit on',
      () {
        expect(lStar(dark.divider), greaterThan(lStar(dark.surface)));
        expect(lStar(dark.hairline), greaterThan(lStar(dark.surface)));
        // ...and hairline stays the quieter of the two.
        expect(lStar(dark.hairline), lessThan(lStar(dark.divider)));
      },
    );
  });

  group('accents and status pills', () {
    test('every accent foreground clears AA large on the canvas', () {
      final accents = {
        'accentPurple': dark.accentPurple,
        'accentPeriwinkle': dark.accentPeriwinkle,
        'accentButter': dark.accentButter,
        'accentBlush': dark.accentBlush,
        'accentMint': dark.accentMint,
      };
      for (final a in accents.entries) {
        expectAtLeast(a.value, canvas, 4.5, a.key);
      }
    });

    test('each accent foreground is legible on its own tile', () {
      final pairs = {
        'purple': [dark.accentPurple, dark.accentPurpleTile],
        'periwinkle': [dark.accentPeriwinkle, dark.accentPeriwinkleTile],
        'butter': [dark.accentButter, dark.accentButterTile],
        'blush': [dark.accentBlush, dark.accentBlushTile],
        'mint': [dark.accentMint, dark.accentMintTile],
      };
      for (final p in pairs.entries) {
        expectAtLeast(p.value[0], p.value[1], 4.5, '${p.key} on its tile');
      }
    });

    test('accent tiles are dark fills, never light pastels', () {
      // The rule measured across Radix/M3/Primer: a light-mode pastel is never
      // reused as a dark-mode background. Anything above L* 25 down here is a
      // pastel that leaked through.
      final tiles = {
        'purpleTile': dark.accentPurpleTile,
        'periwinkleTile': dark.accentPeriwinkleTile,
        'periwinkleChip': dark.accentPeriwinkleChip,
        'butterTile': dark.accentButterTile,
        'butterCream': dark.accentButterCream,
        'blushTile': dark.accentBlushTile,
        'mintTile': dark.accentMintTile,
      };
      for (final t in tiles.entries) {
        expect(
          lStar(t.value),
          lessThan(25.0),
          reason:
              '${t.key} is L* ${lStar(t.value).toStringAsFixed(1)} — a light '
              'pastel used as a dark fill',
        );
      }
    });

    test('status pill text clears AA on its own pill', () {
      final pills = {
        'normal': [dark.statusNormalText, dark.statusNormalBg],
        'elevated': [dark.statusElevatedText, dark.statusElevatedBg],
        'alert': [dark.statusAlertText, dark.statusAlertBg],
        'active': [dark.statusActiveText, dark.statusActiveBg],
        'invited': [dark.statusInvitedText, dark.statusInvitedBg],
      };
      for (final p in pills.entries) {
        expectAtLeast(p.value[0], p.value[1], 4.5, '${p.key} pill text');
      }
    });

    test('status dots are visible on their pill', () {
      final dots = {
        'normal': [dark.statusNormalDot, dark.statusNormalBg],
        'elevated': [dark.statusElevatedDot, dark.statusElevatedBg],
        'alert': [dark.statusAlertDot, dark.statusAlertBg],
        'active': [dark.statusActiveDot, dark.statusActiveBg],
      };
      for (final d in dots.entries) {
        expectAtLeast(d.value[0], d.value[1], 3.0, '${d.key} dot');
      }
    });

    test('status pills read as raised chips on the canvas', () {
      for (final bg in [
        dark.statusNormalBg,
        dark.statusElevatedBg,
        dark.statusAlertBg,
        dark.statusActiveBg,
        dark.statusInvitedBg,
      ]) {
        expect(lStar(bg) - lStar(canvas), greaterThan(4.0));
      }
    });
  });

  group('primary and feedback', () {
    test('primary is legible on the canvas and on a card', () {
      expectAtLeast(dark.primary, canvas, 4.5, 'primary on canvas');
      expectAtLeast(dark.primary, surface, 4.5, 'primary on surface');
    });

    test('onPrimary is legible on primary', () {
      expectAtLeast(dark.onPrimary, dark.primary, 4.5, 'onPrimary');
    });

    test('feedback colours clear AA large on the canvas', () {
      expectAtLeast(dark.error, canvas, 4.5, 'error');
      expectAtLeast(dark.success, canvas, 4.5, 'success');
      expectAtLeast(dark.warning, canvas, 4.5, 'warning');
      expectAtLeast(dark.info, canvas, 4.5, 'info');
    });

    test('onError is legible on error', () {
      expectAtLeast(dark.onError, dark.error, 4.5, 'onError');
    });

    test('the hue of each role is preserved across themes', () {
      // The transform moves lightness and holds hue. |dH| <= 6deg is the bound
      // measured across Apple, M3, Radix and Primer token sources.
      final pairs = {
        'primary': [light.primary, dark.primary],
        'error': [light.error, dark.error],
        'success': [light.success, dark.success],
        'warning': [light.warning, dark.warning],
        'info': [light.info, dark.info],
      };
      for (final p in pairs.entries) {
        final lh = HSLColor.fromColor(p.value[0]).hue;
        final dh = HSLColor.fromColor(p.value[1]).hue;
        var delta = (lh - dh).abs();
        if (delta > 180) delta = 360 - delta;
        expect(
          delta,
          lessThanOrEqualTo(6.0),
          reason:
              '${p.key} hue moved ${delta.toStringAsFixed(1)}deg '
              '($lh -> $dh)',
        );
      }
    });
  });

  group('the dark palette is genuinely its own palette', () {
    test('no surface or text field falls through to a light value', () {
      // 31 of 48 fields used to be byte-identical to light, which is why every
      // badge was a near-white chip on near-black.
      final shared = <String>[];
      void check(String name, Color l, Color d) {
        if (l == d) shared.add(name);
      }

      check('primary', light.primary, dark.primary);
      check('surface', light.surface, dark.surface);
      check('background', light.background, dark.background);
      check('surfaceRecessed', light.surfaceRecessed, dark.surfaceRecessed);
      check('hairline', light.hairline, dark.hairline);
      check('divider', light.divider, dark.divider);
      check('textPrimary', light.textPrimary, dark.textPrimary);
      check('textSecondary', light.textSecondary, dark.textSecondary);
      check('textTertiary', light.textTertiary, dark.textTertiary);
      check('error', light.error, dark.error);
      check('success', light.success, dark.success);
      check('warning', light.warning, dark.warning);
      check('info', light.info, dark.info);
      check('accentPurpleTile', light.accentPurpleTile, dark.accentPurpleTile);
      check(
        'accentPeriwinkleTile',
        light.accentPeriwinkleTile,
        dark.accentPeriwinkleTile,
      );
      check('accentButterTile', light.accentButterTile, dark.accentButterTile);
      check(
        'accentButterCream',
        light.accentButterCream,
        dark.accentButterCream,
      );
      check('accentBlushTile', light.accentBlushTile, dark.accentBlushTile);
      check('accentMintTile', light.accentMintTile, dark.accentMintTile);
      check('statusNormalBg', light.statusNormalBg, dark.statusNormalBg);
      check('statusElevatedBg', light.statusElevatedBg, dark.statusElevatedBg);
      check('statusAlertBg', light.statusAlertBg, dark.statusAlertBg);
      check('statusActiveBg', light.statusActiveBg, dark.statusActiveBg);
      check('statusInvitedBg', light.statusInvitedBg, dark.statusInvitedBg);
      check('statusNormalText', light.statusNormalText, dark.statusNormalText);
      check('statusAlertText', light.statusAlertText, dark.statusAlertText);
      check('statusActiveText', light.statusActiveText, dark.statusActiveText);
      check('knobFill', light.knobFill, dark.knobFill);
      check('toggleTrackOn', light.toggleTrackOn, dark.toggleTrackOn);
      check('toggleTrackOff', light.toggleTrackOff, dark.toggleTrackOff);
      check('disabledSurface', light.disabledSurface, dark.disabledSurface);

      expect(
        shared,
        isEmpty,
        reason: 'these dark fields still hold their light value: $shared',
      );
    });

    test('every dark surface stays in the warm 30-50deg hue band', () {
      // The light theme's identity is warm cream (pcBg, hue 40deg). Dark keeps
      // that hue at low saturation; drifting cool would break the family
      // resemblance, and over-warming would look brown.
      final surfaces = {
        'canvas': canvas,
        'well': well,
        'surface': surface,
        'elevated': elevated,
        'hairline': AppPrimitives.pcDarkHairline,
        'divider': AppPrimitives.pcDarkDivider,
        'textPrimary': dark.textPrimary,
        'textSecondary': dark.textSecondary,
      };
      for (final s in surfaces.entries) {
        final hsl = HSLColor.fromColor(s.value);
        expect(
          hsl.hue,
          inInclusiveRange(30.0, 50.0),
          reason: '${s.key} hue is ${hsl.hue.toStringAsFixed(1)}deg',
        );
        expect(
          hsl.saturation,
          lessThan(0.30),
          reason:
              '${s.key} saturation is ${hsl.saturation.toStringAsFixed(2)} — '
              'too chromatic for a neutral, it will read brown',
        );
      }
    });
  });
}
