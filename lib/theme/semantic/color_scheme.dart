import 'package:flutter/material.dart';

import '../tokens/colors.dart';

/// Semantic color tokens that map primitive [AppPrimitives] values to
/// UI roles (primary, surface, error, accents, status, etc.).
///
/// Usage: `AppSemanticColors.of(context).primary`
///
/// As of Pet Circle v3 (Claude-Design palette), the light theme points at
/// the `pc*` primitives. The dark theme is a sensible inverted mapping.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryLight,
    required this.primaryLightest,
    required this.surface,
    required this.onSurface,
    required this.background,
    required this.onBackground,
    required this.error,
    required this.onError,
    required this.success,
    required this.warning,
    required this.info,
    required this.divider,
    required this.disabled,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    // ── PC v3 additions ───────────────────────────────────────────────────
    required this.surfaceRecessed,
    required this.hairline,
    required this.accentPurple,
    required this.accentPurpleTile,
    required this.accentPeriwinkle,
    required this.accentPeriwinkleTile,
    required this.accentPeriwinkleChip,
    required this.accentButter,
    required this.accentButterTile,
    required this.accentBlush,
    required this.accentBlushTile,
    required this.accentMint,
    required this.accentMintTile,
    required this.statusNormalBg,
    required this.statusNormalDot,
    required this.statusNormalText,
    required this.statusElevatedBg,
    required this.statusElevatedDot,
    required this.statusElevatedText,
    required this.statusAlertBg,
    required this.statusAlertDot,
    required this.statusAlertText,
    required this.statusActiveBg,
    required this.statusActiveDot,
    required this.statusActiveText,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryLight;
  final Color primaryLightest;
  final Color surface;
  final Color onSurface;
  final Color background;
  final Color onBackground;
  final Color error;
  final Color onError;
  final Color success;
  final Color warning;
  final Color info;
  final Color divider;
  final Color disabled;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  // ── PC v3 additions ────────────────────────────────────────────────────
  final Color surfaceRecessed;
  final Color hairline;
  final Color accentPurple;
  final Color accentPurpleTile;
  final Color accentPeriwinkle;
  final Color accentPeriwinkleTile;
  final Color accentPeriwinkleChip;
  final Color accentButter;
  final Color accentButterTile;
  final Color accentBlush;
  final Color accentBlushTile;
  final Color accentMint;
  final Color accentMintTile;
  final Color statusNormalBg;
  final Color statusNormalDot;
  final Color statusNormalText;
  final Color statusElevatedBg;
  final Color statusElevatedDot;
  final Color statusElevatedText;
  final Color statusAlertBg;
  final Color statusAlertDot;
  final Color statusAlertText;
  final Color statusActiveBg;
  final Color statusActiveDot;
  final Color statusActiveText;

  // ── Light theme (Pet Circle v3 / Claude-Design) ──────────────────────────
  static const light = AppSemanticColors(
    primary: AppPrimitives.pcPurple,
    onPrimary: AppPrimitives.pcSurface,
    primaryLight: AppPrimitives.pcPurpleTile,
    primaryLightest: AppPrimitives.pcRecessed,
    surface: AppPrimitives.pcSurface,
    onSurface: AppPrimitives.pcInk,
    background: AppPrimitives.pcBg,
    onBackground: AppPrimitives.pcInk,
    error: AppPrimitives.pcBlush,
    onError: AppPrimitives.pcSurface,
    success: AppPrimitives.pcMint,
    warning: AppPrimitives.pcButter,
    info: AppPrimitives.pcPeriwinkle,
    divider: AppPrimitives.pcHairline,
    disabled: AppPrimitives.pcInkTertiary,
    textPrimary: AppPrimitives.pcInk,
    textSecondary: AppPrimitives.pcInkSecondary,
    textTertiary: AppPrimitives.pcInkTertiary,
    textDisabled: AppPrimitives.pcInkTertiary,
    surfaceRecessed: AppPrimitives.pcRecessed,
    hairline: AppPrimitives.pcHairline,
    accentPurple: AppPrimitives.pcPurple,
    accentPurpleTile: AppPrimitives.pcPurpleTile,
    accentPeriwinkle: AppPrimitives.pcPeriwinkle,
    accentPeriwinkleTile: AppPrimitives.pcPeriwinkleTile,
    accentPeriwinkleChip: AppPrimitives.pcPeriwinkleChip,
    accentButter: AppPrimitives.pcButter,
    accentButterTile: AppPrimitives.pcButterTile,
    accentBlush: AppPrimitives.pcBlush,
    accentBlushTile: AppPrimitives.pcBlushTile,
    accentMint: AppPrimitives.pcMint,
    accentMintTile: AppPrimitives.pcMintTile,
    statusNormalBg: AppPrimitives.pcStatusNormalBg,
    statusNormalDot: AppPrimitives.pcStatusNormalDot,
    statusNormalText: AppPrimitives.pcStatusNormalText,
    statusElevatedBg: AppPrimitives.pcStatusElevatedBg,
    statusElevatedDot: AppPrimitives.pcStatusElevatedDot,
    statusElevatedText: AppPrimitives.pcStatusElevatedText,
    statusAlertBg: AppPrimitives.pcStatusAlertBg,
    statusAlertDot: AppPrimitives.pcStatusAlertDot,
    statusAlertText: AppPrimitives.pcStatusAlertText,
    statusActiveBg: AppPrimitives.pcStatusActiveBg,
    statusActiveDot: AppPrimitives.pcStatusActiveDot,
    statusActiveText: AppPrimitives.pcStatusActiveText,
  );

  // ── Dark theme (inverted) ────────────────────────────────────────────────
  static const dark = AppSemanticColors(
    primary: AppPrimitives.pcPurpleTile,
    onPrimary: AppPrimitives.pcInk,
    primaryLight: AppPrimitives.pcPurpleTile,
    primaryLightest: AppPrimitives.inkDarker,
    surface: AppPrimitives.inkDarker,
    onSurface: AppPrimitives.pcSurface,
    background: AppPrimitives.inkDarkest,
    onBackground: AppPrimitives.pcSurface,
    error: AppPrimitives.pcBlush,
    onError: AppPrimitives.pcInk,
    success: AppPrimitives.pcMint,
    warning: AppPrimitives.pcButter,
    info: AppPrimitives.pcPeriwinkle,
    divider: AppPrimitives.inkBase,
    disabled: AppPrimitives.inkDark,
    textPrimary: AppPrimitives.pcSurface,
    textSecondary: AppPrimitives.skyDark,
    textTertiary: AppPrimitives.skyBase,
    textDisabled: AppPrimitives.inkLighter,
    surfaceRecessed: AppPrimitives.inkDark,
    hairline: AppPrimitives.inkBase,
    accentPurple: AppPrimitives.pcPurple,
    accentPurpleTile: AppPrimitives.pcPurpleTile,
    accentPeriwinkle: AppPrimitives.pcPeriwinkle,
    accentPeriwinkleTile: AppPrimitives.pcPeriwinkleTile,
    accentPeriwinkleChip: AppPrimitives.pcPeriwinkleChip,
    accentButter: AppPrimitives.pcButter,
    accentButterTile: AppPrimitives.pcButterTile,
    accentBlush: AppPrimitives.pcBlush,
    accentBlushTile: AppPrimitives.pcBlushTile,
    accentMint: AppPrimitives.pcMint,
    accentMintTile: AppPrimitives.pcMintTile,
    statusNormalBg: AppPrimitives.pcStatusNormalBg,
    statusNormalDot: AppPrimitives.pcStatusNormalDot,
    statusNormalText: AppPrimitives.pcStatusNormalText,
    statusElevatedBg: AppPrimitives.pcStatusElevatedBg,
    statusElevatedDot: AppPrimitives.pcStatusElevatedDot,
    statusElevatedText: AppPrimitives.pcStatusElevatedText,
    statusAlertBg: AppPrimitives.pcStatusAlertBg,
    statusAlertDot: AppPrimitives.pcStatusAlertDot,
    statusAlertText: AppPrimitives.pcStatusAlertText,
    statusActiveBg: AppPrimitives.pcStatusActiveBg,
    statusActiveDot: AppPrimitives.pcStatusActiveDot,
    statusActiveText: AppPrimitives.pcStatusActiveText,
  );

  /// Convenience accessor. Falls back to [light] when no theme extension is
  /// present (e.g. a bare `MaterialApp()` in a widget test) instead of
  /// throwing on the null-check operator.
  static AppSemanticColors of(BuildContext context) =>
      Theme.of(context).extension<AppSemanticColors>() ?? light;

  @override
  AppSemanticColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryLight,
    Color? primaryLightest,
    Color? surface,
    Color? onSurface,
    Color? background,
    Color? onBackground,
    Color? error,
    Color? onError,
    Color? success,
    Color? warning,
    Color? info,
    Color? divider,
    Color? disabled,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? surfaceRecessed,
    Color? hairline,
    Color? accentPurple,
    Color? accentPurpleTile,
    Color? accentPeriwinkle,
    Color? accentPeriwinkleTile,
    Color? accentPeriwinkleChip,
    Color? accentButter,
    Color? accentButterTile,
    Color? accentBlush,
    Color? accentBlushTile,
    Color? accentMint,
    Color? accentMintTile,
    Color? statusNormalBg,
    Color? statusNormalDot,
    Color? statusNormalText,
    Color? statusElevatedBg,
    Color? statusElevatedDot,
    Color? statusElevatedText,
    Color? statusAlertBg,
    Color? statusAlertDot,
    Color? statusAlertText,
    Color? statusActiveBg,
    Color? statusActiveDot,
    Color? statusActiveText,
  }) {
    return AppSemanticColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryLightest: primaryLightest ?? this.primaryLightest,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      divider: divider ?? this.divider,
      disabled: disabled ?? this.disabled,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      surfaceRecessed: surfaceRecessed ?? this.surfaceRecessed,
      hairline: hairline ?? this.hairline,
      accentPurple: accentPurple ?? this.accentPurple,
      accentPurpleTile: accentPurpleTile ?? this.accentPurpleTile,
      accentPeriwinkle: accentPeriwinkle ?? this.accentPeriwinkle,
      accentPeriwinkleTile: accentPeriwinkleTile ?? this.accentPeriwinkleTile,
      accentPeriwinkleChip: accentPeriwinkleChip ?? this.accentPeriwinkleChip,
      accentButter: accentButter ?? this.accentButter,
      accentButterTile: accentButterTile ?? this.accentButterTile,
      accentBlush: accentBlush ?? this.accentBlush,
      accentBlushTile: accentBlushTile ?? this.accentBlushTile,
      accentMint: accentMint ?? this.accentMint,
      accentMintTile: accentMintTile ?? this.accentMintTile,
      statusNormalBg: statusNormalBg ?? this.statusNormalBg,
      statusNormalDot: statusNormalDot ?? this.statusNormalDot,
      statusNormalText: statusNormalText ?? this.statusNormalText,
      statusElevatedBg: statusElevatedBg ?? this.statusElevatedBg,
      statusElevatedDot: statusElevatedDot ?? this.statusElevatedDot,
      statusElevatedText: statusElevatedText ?? this.statusElevatedText,
      statusAlertBg: statusAlertBg ?? this.statusAlertBg,
      statusAlertDot: statusAlertDot ?? this.statusAlertDot,
      statusAlertText: statusAlertText ?? this.statusAlertText,
      statusActiveBg: statusActiveBg ?? this.statusActiveBg,
      statusActiveDot: statusActiveDot ?? this.statusActiveDot,
      statusActiveText: statusActiveText ?? this.statusActiveText,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryLightest:
          Color.lerp(primaryLightest, other.primaryLightest, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      surfaceRecessed:
          Color.lerp(surfaceRecessed, other.surfaceRecessed, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentPurpleTile:
          Color.lerp(accentPurpleTile, other.accentPurpleTile, t)!,
      accentPeriwinkle:
          Color.lerp(accentPeriwinkle, other.accentPeriwinkle, t)!,
      accentPeriwinkleTile:
          Color.lerp(accentPeriwinkleTile, other.accentPeriwinkleTile, t)!,
      accentPeriwinkleChip:
          Color.lerp(accentPeriwinkleChip, other.accentPeriwinkleChip, t)!,
      accentButter: Color.lerp(accentButter, other.accentButter, t)!,
      accentButterTile:
          Color.lerp(accentButterTile, other.accentButterTile, t)!,
      accentBlush: Color.lerp(accentBlush, other.accentBlush, t)!,
      accentBlushTile:
          Color.lerp(accentBlushTile, other.accentBlushTile, t)!,
      accentMint: Color.lerp(accentMint, other.accentMint, t)!,
      accentMintTile: Color.lerp(accentMintTile, other.accentMintTile, t)!,
      statusNormalBg: Color.lerp(statusNormalBg, other.statusNormalBg, t)!,
      statusNormalDot: Color.lerp(statusNormalDot, other.statusNormalDot, t)!,
      statusNormalText:
          Color.lerp(statusNormalText, other.statusNormalText, t)!,
      statusElevatedBg:
          Color.lerp(statusElevatedBg, other.statusElevatedBg, t)!,
      statusElevatedDot:
          Color.lerp(statusElevatedDot, other.statusElevatedDot, t)!,
      statusElevatedText:
          Color.lerp(statusElevatedText, other.statusElevatedText, t)!,
      statusAlertBg: Color.lerp(statusAlertBg, other.statusAlertBg, t)!,
      statusAlertDot: Color.lerp(statusAlertDot, other.statusAlertDot, t)!,
      statusAlertText:
          Color.lerp(statusAlertText, other.statusAlertText, t)!,
      statusActiveBg: Color.lerp(statusActiveBg, other.statusActiveBg, t)!,
      statusActiveDot: Color.lerp(statusActiveDot, other.statusActiveDot, t)!,
      statusActiveText:
          Color.lerp(statusActiveText, other.statusActiveText, t)!,
    );
  }
}
