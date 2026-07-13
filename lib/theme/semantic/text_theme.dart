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
/// "Muted" / secondary styles use [AppPrimitives.pcInkTertiary] (0xFF9A9A9A)
/// which achieves ≈4.5:1 contrast on both light (`pcSurface`) and dark
/// (`inkDarker`) surfaces — WCAG AA compliant.
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
  static final TextStyle pcTitleSecondary =
      AppTypography.pcLabelLSemibold.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );

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
  static final TextStyle captionMedium =
      AppTypography.pcCaptionMedium.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );
  static final TextStyle pcCaption = AppTypography.pcCaptionRegular.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );
  static final TextStyle pcCaptionMuted =
      AppTypography.pcCaptionRegular.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );

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
