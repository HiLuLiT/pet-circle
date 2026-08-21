import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Semantic text styles that map primitive [AppTypography] tokens to
/// UI roles (title, body, label, etc.).
///
/// **Color strategy (dark-mode-safe)**
/// Primary styles have NO hardcoded color — they inherit from the nearest
/// [DefaultTextStyle] (set by [Scaffold]/[Material] via the active
/// [ThemeData.textTheme]). In light mode the default is [AppPrimitives.pcInk];
/// in dark mode the theme provides a light on-surface color automatically.
///
/// "Muted" / secondary styles use [AppPrimitives.pcInkTertiary] (0xFF9A9A9A).
/// Re-measured against the real dark surfaces (this comment previously cited
/// `inkDarker`, which the dark theme never actually painted): 6.60:1 on
/// `pcDarkCanvas`, 6.30:1 on `pcDarkWell`, 5.85:1 on `pcDarkSurface` and
/// 5.23:1 on `pcDarkElevated` — AA everywhere, AAA on the canvas. On light
/// `pcSurface` it is only 2.81:1, which clears AA at large-text sizes only; the
/// styles using it are 12-13px, so prefer `c.textSecondary` for muted body copy
/// in new code.
///
/// It is also a neutral grey in an otherwise warm palette. Retargeting these
/// styles onto `pcInkSecondary`/`pcDarkInkSecondary` is a typography change,
/// deliberately left out of the dark-theme work.
///
/// Call sites that need a specific semantic color (e.g. `c.textPrimary` in a
/// card) override via `.copyWith(color: ...)` as usual.
class AppSemanticTextStyles {
  AppSemanticTextStyles._();

  // ═══════════════════════════════════════════════════════════════════════
  // PC v3 — Claude-Design semantic scale, matches Figma DS node 402-1191
  // ═══════════════════════════════════════════════════════════════════════

  // ── Display ─────────────────────────────────────────────────────────────
  static const TextStyle pcDisplayXxl = AppTypography.pcDisplayXxlBold;
  static const TextStyle pcDisplayXl = AppTypography.pcDisplayXlBold;
  static const TextStyle pcDisplayL = AppTypography.pcDisplayLBold;
  static const TextStyle pcDisplay = AppTypography.pcDisplayMBold;

  // ── Heading ─────────────────────────────────────────────────────────────
  static const TextStyle headingH1 = AppTypography.pcHeadingH1Bold;
  static const TextStyle headingH2 = AppTypography.pcHeadingH2Bold;
  static const TextStyle headingXs = AppTypography.pcHeadingXsBold;

  // ── Title — retired DS-less 19px scale; now maps onto Heading ───────────
  static const TextStyle pcTitle = headingXs;
  static final TextStyle pcTitleSecondary = AppTypography.pcLabelLSemibold
      .copyWith(color: AppPrimitives.pcInkTertiary);

  // ── Body (16px / line-height 24) ────────────────────────────────────────
  static const TextStyle pcBody = AppTypography.pcBodyRegular;
  static const TextStyle pcBodyMedium = AppTypography.pcBodyMedium;
  static const TextStyle pcBodySemibold = AppTypography.pcBodySemibold;
  static const TextStyle pcBodyBold = AppTypography.pcBodyBold;
  static final TextStyle pcBodyMuted = AppTypography.pcBodyRegular.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );

  // ── Label / L (15px) ────────────────────────────────────────────────────
  static const TextStyle labelLBold = AppTypography.pcLabelLBold;
  static const TextStyle labelLSemibold = AppTypography.pcLabelLSemibold;
  static const TextStyle labelLRegular = AppTypography.pcLabelLRegular;

  // ── Label / M (14px) ────────────────────────────────────────────────────
  static const TextStyle pcLabel = AppTypography.pcLabelMedium;
  static const TextStyle pcLabelBold = AppTypography.pcLabelBold;
  static const TextStyle labelMSemibold = AppTypography.pcLabelSemibold;
  static final TextStyle pcLabelMuted = AppTypography.pcLabelRegular.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );

  // ── Label / S (13px) ────────────────────────────────────────────────────
  static const TextStyle labelSBold = AppTypography.pcLabelSBold;
  static const TextStyle labelSSemibold = AppTypography.pcLabelSSemibold;
  static const TextStyle labelSRegular = AppTypography.pcLabelSRegular;

  // ── Caption (12px / line-height 16) ─────────────────────────────────────
  static const TextStyle captionBold = AppTypography.pcCaptionBold;
  static final TextStyle captionMedium = AppTypography.pcCaptionMedium.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );
  static final TextStyle pcCaption = AppTypography.pcCaptionRegular.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );
  static final TextStyle pcCaptionMuted = AppTypography.pcCaptionRegular
      .copyWith(color: AppPrimitives.pcInkTertiary);

  // ── Button (16px bold, matches DS Button component text) ───────────────
  static const TextStyle pcButton = AppTypography.pcHeadingXsBold;

  // ═══════════════════════════════════════════════════════════════════════
  // Legacy semantic styles — retargeted onto the DS-aligned pc* primitives
  // (nearest matching size/weight). Names kept for backward compat.
  // ═══════════════════════════════════════════════════════════════════════

  // ── Titles ───────────────────────────────────────────────────────────────
  static const TextStyle title1 = AppTypography.pcDisplayXlBold;
  static const TextStyle title2 = AppTypography.pcDisplayLBold;
  static const TextStyle title3 = AppTypography.pcHeadingH1Bold;

  // ── Headings ─────────────────────────────────────────────────────────────
  static const TextStyle headingLg = AppTypography.pcHeadingH2Bold;
  static const TextStyle headingMd = AppTypography.pcHeadingXsBold;

  // ── Body ─────────────────────────────────────────────────────────────────
  static const TextStyle bodyLg = AppTypography.largeNormalRegular;
  static const TextStyle body = AppTypography.pcBodyRegular;
  static const TextStyle bodySm = AppTypography.pcLabelRegular;
  static final TextStyle bodyMuted = AppTypography.pcBodyRegular.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );

  // ── Labels ───────────────────────────────────────────────────────────────
  static const TextStyle label = AppTypography.pcLabelBold;
  static const TextStyle labelSm = AppTypography.pcCaptionBold;

  // ── Button ───────────────────────────────────────────────────────────────
  static const TextStyle button = AppTypography.pcHeadingXsBold;

  // ── Caption ──────────────────────────────────────────────────────────────
  static const TextStyle caption = AppTypography.pcCaptionRegular;
}

/// Keeps [TextStyle.fontWeight] and the Instrument Sans `wght` axis in sync.
///
/// Plain `copyWith(fontWeight: ...)` cannot change the rendered weight of a
/// variable font — the `fontVariations` already on the style take precedence.
/// Use this instead.
extension AppTextStyleWeight on TextStyle {
  TextStyle withWeight(FontWeight weight) => copyWith(
    fontWeight: weight,
    fontVariations: AppTypography.axesFor(weight),
  );
}
