import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Semantic text styles that map primitive [AppTypography] tokens to
/// UI roles (title, body, label, etc.).
///
/// As of Pet Circle v3 (Claude-Design palette), text defaults to
/// [AppPrimitives.pcInk]. New code should prefer the `pc*` styles below;
/// legacy `title1`/`headingLg`/`body`/... accessors are kept for backward
/// compatibility and have been retinted to `pcInk`.
class AppSemanticTextStyles {
  AppSemanticTextStyles._();

  // ═══════════════════════════════════════════════════════════════════════
  // PC v3 — Claude-Design semantic scale, matches Figma DS node 402-1191
  // (use for new code)
  // ═══════════════════════════════════════════════════════════════════════

  // ── Display ─────────────────────────────────────────────────────────────
  static final TextStyle pcDisplayXxl = AppTypography.pcDisplayXxlBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcDisplayXl = AppTypography.pcDisplayXlBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcDisplayL = AppTypography.pcDisplayLBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcDisplay = AppTypography.pcDisplayMBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Heading ─────────────────────────────────────────────────────────────
  static final TextStyle headingH1 = AppTypography.pcHeadingH1Bold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle headingH2 = AppTypography.pcHeadingH2Bold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle headingXs = AppTypography.pcHeadingXsBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Title — retired DS-less 19px scale; now maps onto Heading ───────────
  static final TextStyle pcTitle = headingXs;
  static final TextStyle pcTitleSecondary =
      AppTypography.pcLabelLSemibold.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );

  // ── Body (16px / line-height 24) ────────────────────────────────────────
  static final TextStyle pcBody = AppTypography.pcBodyRegular.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcBodyMedium = AppTypography.pcBodyMedium.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcBodySemibold =
      AppTypography.pcBodySemibold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcBodyBold = AppTypography.pcBodyBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcBodyMuted = AppTypography.pcBodyRegular.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );

  // ── Label / L (15px) ────────────────────────────────────────────────────
  static final TextStyle labelLBold = AppTypography.pcLabelLBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle labelLSemibold =
      AppTypography.pcLabelLSemibold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle labelLRegular =
      AppTypography.pcLabelLRegular.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Label / M (14px) ────────────────────────────────────────────────────
  static final TextStyle pcLabel = AppTypography.pcLabelMedium.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcLabelBold = AppTypography.pcLabelBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle labelMSemibold =
      AppTypography.pcLabelSemibold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcLabelMuted = AppTypography.pcLabelRegular.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );

  // ── Label / S (13px) ────────────────────────────────────────────────────
  static final TextStyle labelSBold = AppTypography.pcLabelSBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle labelSSemibold =
      AppTypography.pcLabelSSemibold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle labelSRegular =
      AppTypography.pcLabelSRegular.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Caption (12px / line-height 16) ─────────────────────────────────────
  static final TextStyle captionBold = AppTypography.pcCaptionBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle captionMedium =
      AppTypography.pcCaptionMedium.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );
  static final TextStyle pcCaption =
      AppTypography.pcCaptionRegular.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );
  static final TextStyle pcCaptionMuted =
      AppTypography.pcCaptionRegular.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );

  // ── Button (16px bold, matches DS Button component text) ───────────────
  static final TextStyle pcButton = AppTypography.pcHeadingXsBold.copyWith(
    color: AppPrimitives.pcInk,
    height: 1.0,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Legacy semantic styles — retargeted onto the DS-aligned pc* primitives
  // above (nearest matching size/weight) so old call sites keep compiling
  // while converging on one canonical scale. Names/sizes kept for compat.
  // ═══════════════════════════════════════════════════════════════════════

  // ── Titles ───────────────────────────────────────────────────────────────
  static final TextStyle title1 = AppTypography.pcDisplayXlBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle title2 = AppTypography.pcDisplayLBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // Exact DS match — Heading/H1 (24/32, -0.3), confirmed against the Figma
  // "Create an account" instance.
  static final TextStyle title3 = AppTypography.pcHeadingH1Bold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Headings ─────────────────────────────────────────────────────────────
  static final TextStyle headingLg = AppTypography.pcHeadingH2Bold.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle headingMd = AppTypography.pcHeadingXsBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  static final TextStyle bodyLg =
      AppTypography.largeNormalRegular.copyWith(
    color: AppPrimitives.pcInk,
  );

  // Exact DS match — Body/Regular (16/24).
  static final TextStyle body = AppTypography.pcBodyRegular.copyWith(
    color: AppPrimitives.pcInk,
  );

  // Exact DS match — Label/M Regular (14/20).
  static final TextStyle bodySm = AppTypography.pcLabelRegular.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle bodyMuted = AppTypography.pcBodyRegular.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );

  // ── Labels ───────────────────────────────────────────────────────────────
  // DS match — Label/M Bold (14/20).
  static final TextStyle label = AppTypography.pcLabelBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // DS match — Caption/Bold (12/16).
  static final TextStyle labelSm = AppTypography.pcCaptionBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Button ───────────────────────────────────────────────────────────────
  // DS match — the Button component's text style (Heading/XS Bold, 16/22).
  static final TextStyle button = AppTypography.pcHeadingXsBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Caption ──────────────────────────────────────────────────────────────
  // DS match — Caption/Regular (12/16).
  static final TextStyle caption = AppTypography.pcCaptionRegular.copyWith(
    color: AppPrimitives.pcInk,
  );
}
