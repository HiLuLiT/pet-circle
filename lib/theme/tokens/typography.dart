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
  // Pet Circle v3 (Claude-Design) scale
  //
  // 5 sizes: display 34, title 19, body 16, label 14, caption 13.
  // Use these for new code. Legacy scale below kept for unmigrated widgets.
  // ═══════════════════════════════════════════════════════════════════════

  // ── PC v3: Display (34px) ───────────────────────────────────────────────
  static const TextStyle pcDisplayBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 40 / 34,
  );

  // ── PC v3: Title (19px) ─────────────────────────────────────────────────
  static const TextStyle pcTitleBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    height: 24 / 19,
  );
  static const TextStyle pcTitleSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 24 / 19,
  );

  // ── PC v3: Body (16px) ──────────────────────────────────────────────────
  static const TextStyle pcBodyRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
  );
  static const TextStyle pcBodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
  );
  static const TextStyle pcBodySemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
  );
  static const TextStyle pcBodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 22 / 16,
  );

  // ── PC v3: Label (14px) ─────────────────────────────────────────────────
  static const TextStyle pcLabelRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );
  static const TextStyle pcLabelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
  );
  static const TextStyle pcLabelSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );
  static const TextStyle pcLabelBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
  );

  // ── PC v3: Caption (13px) ───────────────────────────────────────────────
  static const TextStyle pcCaptionRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
  );
  static const TextStyle pcCaptionMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 18 / 13,
  );
  static const TextStyle pcCaptionSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Legacy v2 scale (do not use in new code)
  // ═══════════════════════════════════════════════════════════════════════

  // ── Title 1 (48px) ──────────────────────────────────────────────────────
  static const TextStyle title1NormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 56 / 48,
  );

  // ── Title 2 (32px) ──────────────────────────────────────────────────────
  static const TextStyle title2NormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 36 / 32,
  );

  // ── Title 3 (24px) ──────────────────────────────────────────────────────
  static const TextStyle title3NormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
  );

  // ── Large (18px) ─────────────────────────────────────────────────────────
  static const TextStyle largeNoneBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 18 / 18,
  );
  static const TextStyle largeNoneMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 18 / 18,
  );
  static const TextStyle largeNoneRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 18 / 18,
  );
  static const TextStyle largeTightBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 20 / 18,
  );
  static const TextStyle largeTightMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 20 / 18,
  );
  static const TextStyle largeTightRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 20 / 18,
  );
  static const TextStyle largeNormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 24 / 18,
  );
  static const TextStyle largeNormalMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
  );
  static const TextStyle largeNormalRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 24 / 18,
  );

  // ── Regular (16px) ───────────────────────────────────────────────────────
  static const TextStyle regularNoneBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 16 / 16,
  );
  static const TextStyle regularNoneMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 16 / 16,
  );
  static const TextStyle regularNoneRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 16 / 16,
  );
  static const TextStyle regularTightBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 20 / 16,
  );
  static const TextStyle regularTightMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 20 / 16,
  );
  static const TextStyle regularTightRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 20 / 16,
  );
  static const TextStyle regularNormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
  );
  static const TextStyle regularNormalMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
  );
  static const TextStyle regularNormalRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  // ── Small (14px) ─────────────────────────────────────────────────────────
  static const TextStyle smallNoneBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 14 / 14,
  );
  static const TextStyle smallNoneMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 14 / 14,
  );
  static const TextStyle smallNoneRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 14 / 14,
  );
  static const TextStyle smallTightBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 16 / 14,
  );
  static const TextStyle smallTightMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 16 / 14,
  );
  static const TextStyle smallTightRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 16 / 14,
  );
  static const TextStyle smallNormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
  );
  static const TextStyle smallNormalMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
  );
  static const TextStyle smallNormalRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  // ── Tiny (12px) ──────────────────────────────────────────────────────────
  static const TextStyle tinyNoneBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 12 / 12,
  );
  static const TextStyle tinyNoneMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 12 / 12,
  );
  static const TextStyle tinyNoneRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 12 / 12,
  );
  static const TextStyle tinyTightBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 14 / 12,
  );
  static const TextStyle tinyTightMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 14 / 12,
  );
  static const TextStyle tinyTightRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 14 / 12,
  );
  static const TextStyle tinyNormalBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
  );
  static const TextStyle tinyNormalMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  );
  static const TextStyle tinyNormalRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );
}
