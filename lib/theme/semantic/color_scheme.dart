import 'package:flutter/material.dart';

import '../tokens/colors.dart';

/// Semantic color tokens that map primitive [AppPrimitives] values to
/// UI roles (primary, surface, error, etc.).
///
/// Usage: `AppSemanticColors.of(context).primary`
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

  // ── Light theme ──────────────────────────────────────────────────────────
  static const light = AppSemanticColors(
    primary: AppPrimitives.primaryBase,
    onPrimary: AppPrimitives.skyWhite,
    primaryLight: AppPrimitives.primaryLight,
    primaryLightest: AppPrimitives.primaryLightest,
    surface: AppPrimitives.skyWhite,
    onSurface: AppPrimitives.inkDarkest,
    background: AppPrimitives.skyLightest,
    onBackground: AppPrimitives.inkDarkest,
    error: AppPrimitives.redBase,
    onError: AppPrimitives.skyWhite,
    success: AppPrimitives.greenBase,
    warning: AppPrimitives.yellowBase,
    info: AppPrimitives.blueBase,
    divider: AppPrimitives.skyLight,
    disabled: AppPrimitives.skyBase,
    textPrimary: AppPrimitives.inkDarkest,
    textSecondary: AppPrimitives.inkLight,
    textTertiary: AppPrimitives.inkLighter,
    textDisabled: AppPrimitives.skyDark,
  );

  // ── Dark theme ───────────────────────────────────────────────────────────
  static const dark = AppSemanticColors(
    primary: AppPrimitives.primaryLight,
    onPrimary: AppPrimitives.inkDarkest,
    primaryLight: AppPrimitives.primaryLighter,
    primaryLightest: AppPrimitives.primaryDark,
    surface: AppPrimitives.inkDarker,
    onSurface: AppPrimitives.skyLightest,
    background: AppPrimitives.inkDarkest,
    onBackground: AppPrimitives.skyLightest,
    error: AppPrimitives.redLight,
    onError: AppPrimitives.inkDarkest,
    success: AppPrimitives.greenLight,
    warning: AppPrimitives.yellowLight,
    info: AppPrimitives.blueLight,
    divider: AppPrimitives.inkBase,
    disabled: AppPrimitives.inkDark,
    textPrimary: AppPrimitives.skyLightest,
    textSecondary: AppPrimitives.skyDark,
    textTertiary: AppPrimitives.skyBase,
    textDisabled: AppPrimitives.inkLighter,
  );

  /// Convenience accessor.
  static AppSemanticColors of(BuildContext context) =>
      Theme.of(context).extension<AppSemanticColors>()!;

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
    );
  }
}
