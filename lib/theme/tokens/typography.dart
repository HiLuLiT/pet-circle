import 'package:flutter/material.dart';

/// Primitive typography tokens from the v2 design system.
///
/// Naming convention: `{size}{LineHeight}{Weight}`
/// - Sizes: title1 (48), title2 (32), title3 (24), large (18),
///   regular (16), small (14), tiny (12)
/// - Line heights: None (= font size), Tight, Normal
/// - Weights: Bold (w700), Medium (w500), Regular (w400)
/// - Titles only have Normal+Bold variant.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Instrument Sans';

  // ═══════════════════════════════════════════════════════════════════════
  // Variable-font axes — REQUIRED for weight to render at all.
  //
  // Instrument Sans ships as a single variable font (`wght` 400–700,
  // `wdth` 75–100) whose *default instance is wght 400*. The eight
  // per-weight entries in pubspec.yaml all point at that same file, and
  // Flutter only uses `fontWeight` to pick a font *file* — it never sets a
  // variation axis. So without these explicit `fontVariations`, every
  // Bold/SemiBold/Medium style below silently renders at Regular weight.
  //
  // `wdth: 100` matches the Figma DS, which specifies
  // `fontVariationSettings: "'wdth' 100"`.
  //
  // `fontWeight` is kept alongside each `fontVariations` so file selection
  // and platform-font fallback still resolve to the right weight.
  // ═══════════════════════════════════════════════════════════════════════

  static const List<FontVariation> _wdth100 = [FontVariation('wdth', 100)];

  static const List<FontVariation> axesRegular = [
    FontVariation('wght', 400),
    ..._wdth100,
  ];
  static const List<FontVariation> axesMedium = [
    FontVariation('wght', 500),
    ..._wdth100,
  ];
  static const List<FontVariation> axesSemibold = [
    FontVariation('wght', 600),
    ..._wdth100,
  ];
  static const List<FontVariation> axesBold = [
    FontVariation('wght', 700),
    ..._wdth100,
  ];

  /// Variable-font axes matching [weight]. Weights between the named steps
  /// are clamped to the font's 400–700 `wght` range.
  static List<FontVariation> axesFor(FontWeight weight) => [
    FontVariation('wght', weight.value.clamp(400, 700).toDouble()),
    ..._wdth100,
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // Pet Circle v3 (Claude-Design) scale — matches Figma DS node 402-1191.
  //
  // Display (56/40/36/28) · Heading (H1 24, H2 20, XS 16) · Label (L 15,
  // M 14, S 13) · Body (16) · Caption (12, Tag 11, XS 10).
  // Use these for new code. Legacy scale below kept for unmigrated widgets.
  // ═══════════════════════════════════════════════════════════════════════

  // ── PC v3: Display — Bold only ──────────────────────────────────────────
  static const TextStyle pcDisplayXxlBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 64 / 56,
  );
  static const TextStyle pcDisplayXlBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 48 / 40,
  );
  static const TextStyle pcDisplayLBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 44 / 36,
  );
  static const TextStyle pcDisplayMBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 36 / 28,
    // Figma reports Display/M letter spacing as -0.5 *percent*, which the
    // rendered node resolves to -0.14px at 28px (28 * -0.005). Flutter's
    // letterSpacing is in logical px, so -0.5 was ~3.5x too tight.
    letterSpacing: -0.14,
  );

  // ── PC v3: Heading — Bold only ──────────────────────────────────────────
  static const TextStyle pcHeadingH1Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 32 / 24,
    letterSpacing: -0.3,
  );
  static const TextStyle pcHeadingH2Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 28 / 20,
    letterSpacing: -0.2,
  );
  static const TextStyle pcHeadingXsBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 22 / 16,
  );

  // ── PC v3: Label / L (15px) ─────────────────────────────────────────────
  static const TextStyle pcLabelLBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 20 / 15,
  );
  static const TextStyle pcLabelLSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontVariations: axesSemibold,
    height: 20 / 15,
  );
  static const TextStyle pcLabelLRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 20 / 15,
  );

  // ── PC v3: Label / M (14px) ─────────────────────────────────────────────
  static const TextStyle pcLabelRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 20 / 14,
  );
  static const TextStyle pcLabelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 20 / 14,
  );
  static const TextStyle pcLabelSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontVariations: axesSemibold,
    height: 20 / 14,
  );
  static const TextStyle pcLabelBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 20 / 14,
  );

  // ── PC v3: Label / S (13px) ─────────────────────────────────────────────
  static const TextStyle pcLabelSBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 18 / 13,
  );
  static const TextStyle pcLabelSSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontVariations: axesSemibold,
    height: 18 / 13,
  );
  static const TextStyle pcLabelSRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 18 / 13,
  );

  // ── PC v3: Body (16px, line-height 24) ──────────────────────────────────
  static const TextStyle pcBodyRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 24 / 16,
  );
  static const TextStyle pcBodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 24 / 16,
  );
  static const TextStyle pcBodySemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontVariations: axesSemibold,
    height: 24 / 16,
  );
  // Not a distinct DS style (DS Body has no Bold weight) — kept for call
  // sites that need a bold 16px run; matches Body line-height for alignment.
  static const TextStyle pcBodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 24 / 16,
  );

  // ── PC v3: Caption (12px, line-height 16) ───────────────────────────────
  static const TextStyle pcCaptionBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 16 / 12,
  );
  static const TextStyle pcCaptionMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 16 / 12,
    letterSpacing: 0.1,
  );
  static const TextStyle pcCaptionRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 16 / 12,
  );
  // Caption/Tag — 11px, Bold, +0.5 tracking (chip tags, "NEW" badges).
  static const TextStyle pcCaptionTagBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 16 / 11,
    letterSpacing: 0.5,
  );
  // Caption/XS — 10px, Bold (avatar initials, tiny tags).
  static const TextStyle pcCaptionXsBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 14 / 10,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Legacy v2 scale (do not use in new code)
  // ═══════════════════════════════════════════════════════════════════════

  // ── Title 1 (48px) ──────────────────────────────────────────────────────
  static const TextStyle title1NormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 56 / 48,
  );

  // ── Title 2 (32px) ──────────────────────────────────────────────────────
  static const TextStyle title2NormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 36 / 32,
  );

  // ── Title 3 (24px) ──────────────────────────────────────────────────────
  static const TextStyle title3NormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 32 / 24,
  );

  // ── Large (18px) ─────────────────────────────────────────────────────────
  static const TextStyle largeNoneBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 18 / 18,
  );
  static const TextStyle largeNoneMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 18 / 18,
  );
  static const TextStyle largeNoneRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 18 / 18,
  );
  static const TextStyle largeTightBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 20 / 18,
  );
  static const TextStyle largeTightMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 20 / 18,
  );
  static const TextStyle largeTightRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 20 / 18,
  );
  static const TextStyle largeNormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 24 / 18,
  );
  static const TextStyle largeNormalMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 24 / 18,
  );
  static const TextStyle largeNormalRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 24 / 18,
  );

  // ── Regular (16px) ───────────────────────────────────────────────────────
  static const TextStyle regularNoneBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 16 / 16,
  );
  static const TextStyle regularNoneMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 16 / 16,
  );
  static const TextStyle regularNoneRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 16 / 16,
  );
  static const TextStyle regularTightBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 20 / 16,
  );
  static const TextStyle regularTightMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 20 / 16,
  );
  static const TextStyle regularTightRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 20 / 16,
  );
  static const TextStyle regularNormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 24 / 16,
  );
  static const TextStyle regularNormalMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 24 / 16,
  );
  static const TextStyle regularNormalRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 24 / 16,
  );

  // ── Small (14px) ─────────────────────────────────────────────────────────
  static const TextStyle smallNoneBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 14 / 14,
  );
  static const TextStyle smallNoneMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 14 / 14,
  );
  static const TextStyle smallNoneRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 14 / 14,
  );
  static const TextStyle smallTightBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 16 / 14,
  );
  static const TextStyle smallTightMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 16 / 14,
  );
  static const TextStyle smallTightRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 16 / 14,
  );
  static const TextStyle smallNormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 20 / 14,
  );
  static const TextStyle smallNormalMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 20 / 14,
  );
  static const TextStyle smallNormalRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 20 / 14,
  );

  // ── Tiny (12px) ──────────────────────────────────────────────────────────
  static const TextStyle tinyNoneBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 12 / 12,
  );
  static const TextStyle tinyNoneMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 12 / 12,
  );
  static const TextStyle tinyNoneRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 12 / 12,
  );
  static const TextStyle tinyTightBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 14 / 12,
  );
  static const TextStyle tinyTightMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 14 / 12,
  );
  static const TextStyle tinyTightRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 14 / 12,
  );
  static const TextStyle tinyNormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    fontVariations: axesBold,
    height: 16 / 12,
  );
  static const TextStyle tinyNormalMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontVariations: axesMedium,
    height: 16 / 12,
  );
  static const TextStyle tinyNormalRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontVariations: axesRegular,
    height: 16 / 12,
  );
}
