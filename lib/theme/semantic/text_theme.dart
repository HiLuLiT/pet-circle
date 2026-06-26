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
  // PC v3 — Claude-Design semantic scale (use for new code)
  // ═══════════════════════════════════════════════════════════════════════

  // ── Display (34px) ──────────────────────────────────────────────────────
  static final TextStyle pcDisplay = AppTypography.pcDisplayBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Title (19px) ────────────────────────────────────────────────────────
  static final TextStyle pcTitle = AppTypography.pcTitleBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcTitleSecondary =
      AppTypography.pcTitleSemibold.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );

  // ── Body (16px) ─────────────────────────────────────────────────────────
  static final TextStyle pcBody = AppTypography.pcBodyRegular.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcBodyMedium = AppTypography.pcBodyMedium.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcBodyBold = AppTypography.pcBodyBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcBodyMuted = AppTypography.pcBodyRegular.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );

  // ── Label (14px) ────────────────────────────────────────────────────────
  static final TextStyle pcLabel = AppTypography.pcLabelMedium.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcLabelBold = AppTypography.pcLabelBold.copyWith(
    color: AppPrimitives.pcInk,
  );
  static final TextStyle pcLabelMuted = AppTypography.pcLabelRegular.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );

  // ── Caption (13px) ──────────────────────────────────────────────────────
  static final TextStyle pcCaption =
      AppTypography.pcCaptionRegular.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );
  static final TextStyle pcCaptionMuted =
      AppTypography.pcCaptionRegular.copyWith(
    color: AppPrimitives.pcInkTertiary,
  );

  // ── Button (16px medium) ────────────────────────────────────────────────
  static final TextStyle pcButton = AppTypography.pcBodyBold.copyWith(
    color: AppPrimitives.pcInk,
    height: 1.0,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Legacy semantic styles (retinted to pcInk — sizes kept for compat)
  // ═══════════════════════════════════════════════════════════════════════

  // ── Titles ───────────────────────────────────────────────────────────────
  static final TextStyle title1 = AppTypography.title1NormalBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle title2 = AppTypography.title2NormalBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle title3 = AppTypography.title3NormalBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Headings ─────────────────────────────────────────────────────────────
  static final TextStyle headingLg = AppTypography.largeNormalBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle headingMd =
      AppTypography.regularNormalBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  static final TextStyle bodyLg =
      AppTypography.largeNormalRegular.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle body =
      AppTypography.regularNormalRegular.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle bodySm =
      AppTypography.smallNormalRegular.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle bodyMuted =
      AppTypography.regularNormalRegular.copyWith(
    color: AppPrimitives.pcInkSecondary,
  );

  // ── Labels ───────────────────────────────────────────────────────────────
  static final TextStyle label = AppTypography.smallNoneBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  static final TextStyle labelSm = AppTypography.tinyNoneBold.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Button ───────────────────────────────────────────────────────────────
  static final TextStyle button =
      AppTypography.regularNoneMedium.copyWith(
    color: AppPrimitives.pcInk,
  );

  // ── Caption ──────────────────────────────────────────────────────────────
  static final TextStyle caption = AppTypography.tinyNoneRegular.copyWith(
    color: AppPrimitives.pcInk,
  );
}
