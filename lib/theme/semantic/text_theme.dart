import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Semantic text styles that map primitive [AppTypography] tokens to
/// UI roles (title, body, label, etc.).
///
/// All styles default to [AppPrimitives.inkDarkest] and
/// [AppTypography.fontFamily].
class AppSemanticTextStyles {
  AppSemanticTextStyles._();

  // ── Titles ───────────────────────────────────────────────────────────────
  static final TextStyle title1 = AppTypography.title1NormalBold.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  static final TextStyle title2 = AppTypography.title2NormalBold.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  static final TextStyle title3 = AppTypography.title3NormalBold.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  // ── Headings ─────────────────────────────────────────────────────────────
  static final TextStyle headingLg = AppTypography.largeNormalBold.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  static final TextStyle headingMd =
      AppTypography.regularNormalBold.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  static final TextStyle bodyLg =
      AppTypography.largeNormalRegular.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  static final TextStyle body =
      AppTypography.regularNormalRegular.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  static final TextStyle bodySm =
      AppTypography.smallNormalRegular.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  static final TextStyle bodyMuted =
      AppTypography.regularNormalRegular.copyWith(
    color: AppPrimitives.inkLight,
  );

  // ── Labels ───────────────────────────────────────────────────────────────
  static final TextStyle label = AppTypography.smallNoneBold.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  static final TextStyle labelSm = AppTypography.tinyNoneBold.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  // ── Button ───────────────────────────────────────────────────────────────
  static final TextStyle button =
      AppTypography.regularNoneMedium.copyWith(
    color: AppPrimitives.inkDarkest,
  );

  // ── Caption ──────────────────────────────────────────────────────────────
  static final TextStyle caption = AppTypography.tinyNoneRegular.copyWith(
    color: AppPrimitives.inkDarkest,
  );
}
