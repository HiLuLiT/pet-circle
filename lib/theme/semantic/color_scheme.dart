import 'package:flutter/material.dart';

import '../tokens/colors.dart';

/// Semantic color tokens that map primitive [AppPrimitives] values to
/// UI roles (primary, surface, error, accents, status, etc.).
///
/// Usage: `AppSemanticColors.of(context).primary`
///
/// As of Pet Circle v3 (Claude-Design palette), the light theme points at the
/// `pc*` primitives and the dark theme at the `pcDark*` set.
///
/// Dark is a **per-role transform**, not an inversion. Each role gets its own
/// dark value: a wash/tile drops to L* 13-17, a solid accent is roughly held,
/// and a text/icon accent is lifted — while hue stays put. Critically, no field
/// falls through to a light-mode primitive; reusing light pastels as dark fills
/// is what made every badge in the app a floodlight on near-black. See
/// [AppPrimitives] "Warm Charcoal" for the derivation and the measured ratios,
/// and test/theme/dark_contrast_test.dart for the assertions.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryLight,
    required this.primaryLightest,
    required this.primaryGhost,
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
    required this.disabledSurface,
    required this.disabledOnSurface,
    required this.knobFill,
    required this.toggleTrackOn,
    required this.toggleTrackOff,
    required this.accentPurple,
    required this.accentPurpleTile,
    required this.accentPeriwinkle,
    required this.accentPeriwinkleTile,
    required this.accentPeriwinkleChip,
    required this.accentButter,
    required this.accentButterTile,
    required this.accentButterCream,
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
    required this.statusInvitedBg,
    required this.statusInvitedText,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryLight;
  final Color primaryLightest;

  /// Candy/Purple/Ghost (#E7E7FF) — pale wash for avatar tiles / icon
  /// backdrops. Distinct from [primaryLightest] (recessed surface wash).
  final Color primaryGhost;
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

  /// Fill of a disabled filled control (e.g. `PrimaryButton` when
  /// `onPressed == null`). Distinct from [disabled], which is a *content*
  /// colour, not a surface.
  final Color disabledSurface;

  /// Label/icon colour on top of [disabledSurface].
  final Color disabledOnSurface;

  /// The moving knob of a switch or toggle. Reads as "the lightest thing in the
  /// control" in both themes, so it cannot be [surface] (which inverts).
  final Color knobFill;

  /// Track of a switch in its **on** state.
  ///
  /// Deliberately not [accentPurpleTile]: a tile is a *recessed background
  /// wash*, and in dark mode that wash sits at the same luminance as the card
  /// behind it (1.04:1), so an on switch read as a dark hole and was
  /// indistinguishable from an off one (1.06:1). A switch track is a filled
  /// control surface, so dark uses the bright accent instead.
  final Color toggleTrackOn;

  /// Track of a switch in its **off** state — a quiet neutral that still
  /// separates the control from the surface it sits on.
  final Color toggleTrackOff;
  final Color accentPurple;
  final Color accentPurpleTile;
  final Color accentPeriwinkle;
  final Color accentPeriwinkleTile;
  final Color accentPeriwinkleChip;
  final Color accentButter;
  final Color accentButterTile;

  /// Warm cream tile — toggle off-track, note callouts. Light #E8E4D8, dark
  /// #2A2620; it is a *surface*, so it inverts like every other tile.
  final Color accentButterCream;
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
  // Invited (yellow) — pending invitation pill; no dot.
  final Color statusInvitedBg;
  final Color statusInvitedText;

  // ── Light theme (Pet Circle v3 / Claude-Design) ──────────────────────────
  static const light = AppSemanticColors(
    primary: AppPrimitives.pcPurple,
    onPrimary: AppPrimitives.pcSurface,
    primaryLight: AppPrimitives.pcPurpleTile,
    primaryLightest: AppPrimitives.pcRecessed,
    primaryGhost: AppPrimitives.pcPurpleGhost,
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
    disabledSurface: AppPrimitives.pcDisabledSurface,
    disabledOnSurface: AppPrimitives.pcDisabledOnSurface,
    knobFill: AppPrimitives.pcSurface,
    // Unchanged from when these were read straight off the accent tiles, so
    // light-mode switches render exactly as the Figma Toggle (465:3781) spec.
    toggleTrackOn: AppPrimitives.pcPurpleTile,
    toggleTrackOff: AppPrimitives.pcButterCream,
    accentPurple: AppPrimitives.pcPurple,
    accentPurpleTile: AppPrimitives.pcPurpleTile,
    accentPeriwinkle: AppPrimitives.pcPeriwinkle,
    accentPeriwinkleTile: AppPrimitives.pcPeriwinkleTile,
    accentPeriwinkleChip: AppPrimitives.pcPeriwinkleChip,
    accentButter: AppPrimitives.pcButter,
    accentButterTile: AppPrimitives.pcButterTile,
    accentButterCream: AppPrimitives.pcButterCream,
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
    statusInvitedBg: AppPrimitives.yellowLightest,
    statusInvitedText: AppPrimitives.yellowDarkest,
  );

  // ── Dark theme ("Warm Charcoal" — per-role transform, see class doc) ─────
  // Every field below resolves to a `pcDark*` primitive. If you add a field to
  // this class, give it a real dark value here — do not let it fall through to
  // a light primitive.
  static const dark = AppSemanticColors(
    primary: AppPrimitives.pcDarkPurple,
    onPrimary: AppPrimitives.pcDarkCanvas,
    primaryLight: AppPrimitives.pcDarkPurpleLight,
    primaryLightest: AppPrimitives.pcDarkPurpleWash,
    primaryGhost: AppPrimitives.pcDarkPurpleGhost,
    surface: AppPrimitives.pcDarkSurface,
    onSurface: AppPrimitives.pcDarkInk,
    background: AppPrimitives.pcDarkCanvas,
    onBackground: AppPrimitives.pcDarkInk,
    error: AppPrimitives.pcDarkBlush,
    onError: AppPrimitives.pcDarkCanvas,
    success: AppPrimitives.pcDarkMint,
    warning: AppPrimitives.pcDarkButter,
    info: AppPrimitives.pcDarkPeriwinkle,
    divider: AppPrimitives.pcDarkDivider,
    disabled: AppPrimitives.pcDarkInkDisabled,
    textPrimary: AppPrimitives.pcDarkInk,
    textSecondary: AppPrimitives.pcDarkInkSecondary,
    textTertiary: AppPrimitives.pcDarkInkTertiary,
    textDisabled: AppPrimitives.pcDarkInkDisabled,
    surfaceRecessed: AppPrimitives.pcDarkWell,
    hairline: AppPrimitives.pcDarkHairline,
    disabledSurface: AppPrimitives.pcDarkElevated,
    disabledOnSurface: AppPrimitives.pcDarkInkDisabled,
    knobFill: AppPrimitives.pcDarkInk,
    // The bright brand accent, not pcDarkPurpleWash: 7.16:1 on a card versus
    // the wash's 1.04:1, and 5.28:1 against the off track so the two states
    // are told apart by colour and not only by knob position.
    toggleTrackOn: AppPrimitives.pcDarkPurple,
    toggleTrackOff: AppPrimitives.pcDarkDivider,
    // Accents: the *tile* is a dedicated dark wash, the *accent* the bright
    // foreground. Note accentPurple/accentPurpleTile deliberately swap register
    // relative to light — pcPurpleTile is the dark foreground.
    accentPurple: AppPrimitives.pcPurpleTile,
    accentPurpleTile: AppPrimitives.pcDarkPurpleWash,
    accentPeriwinkle: AppPrimitives.pcDarkPeriwinkle,
    accentPeriwinkleTile: AppPrimitives.pcDarkPeriwinkleTile,
    accentPeriwinkleChip: AppPrimitives.pcDarkPeriwinkleChip,
    accentButter: AppPrimitives.pcDarkButter,
    accentButterTile: AppPrimitives.pcDarkButterTile,
    accentButterCream: AppPrimitives.pcDarkButterCream,
    accentBlush: AppPrimitives.pcDarkBlush,
    accentBlushTile: AppPrimitives.pcDarkBlushTile,
    accentMint: AppPrimitives.pcDarkMint,
    accentMintTile: AppPrimitives.pcDarkMintTile,
    statusNormalBg: AppPrimitives.pcDarkPeriwinkleTile,
    statusNormalDot: AppPrimitives.pcDarkPeriwinkle,
    statusNormalText: AppPrimitives.pcDarkStatusNormalText,
    statusElevatedBg: AppPrimitives.pcDarkButterTile,
    statusElevatedDot: AppPrimitives.pcDarkButter,
    statusElevatedText: AppPrimitives.pcDarkStatusElevatedText,
    statusAlertBg: AppPrimitives.pcDarkBlushTile,
    statusAlertDot: AppPrimitives.pcDarkBlush,
    statusAlertText: AppPrimitives.pcDarkStatusAlertText,
    statusActiveBg: AppPrimitives.pcDarkMintTile,
    statusActiveDot: AppPrimitives.pcDarkMint,
    statusActiveText: AppPrimitives.pcDarkStatusActiveText,
    statusInvitedBg: AppPrimitives.pcDarkButterTile,
    statusInvitedText: AppPrimitives.pcDarkStatusElevatedText,
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
    Color? primaryGhost,
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
    Color? disabledSurface,
    Color? disabledOnSurface,
    Color? knobFill,
    Color? toggleTrackOn,
    Color? toggleTrackOff,
    Color? accentPurple,
    Color? accentPurpleTile,
    Color? accentPeriwinkle,
    Color? accentPeriwinkleTile,
    Color? accentPeriwinkleChip,
    Color? accentButter,
    Color? accentButterTile,
    Color? accentButterCream,
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
    Color? statusInvitedBg,
    Color? statusInvitedText,
  }) {
    return AppSemanticColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryLightest: primaryLightest ?? this.primaryLightest,
      primaryGhost: primaryGhost ?? this.primaryGhost,
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
      disabledSurface: disabledSurface ?? this.disabledSurface,
      disabledOnSurface: disabledOnSurface ?? this.disabledOnSurface,
      knobFill: knobFill ?? this.knobFill,
      toggleTrackOn: toggleTrackOn ?? this.toggleTrackOn,
      toggleTrackOff: toggleTrackOff ?? this.toggleTrackOff,
      accentPurple: accentPurple ?? this.accentPurple,
      accentPurpleTile: accentPurpleTile ?? this.accentPurpleTile,
      accentPeriwinkle: accentPeriwinkle ?? this.accentPeriwinkle,
      accentPeriwinkleTile: accentPeriwinkleTile ?? this.accentPeriwinkleTile,
      accentPeriwinkleChip: accentPeriwinkleChip ?? this.accentPeriwinkleChip,
      accentButter: accentButter ?? this.accentButter,
      accentButterTile: accentButterTile ?? this.accentButterTile,
      accentButterCream: accentButterCream ?? this.accentButterCream,
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
      statusInvitedBg: statusInvitedBg ?? this.statusInvitedBg,
      statusInvitedText: statusInvitedText ?? this.statusInvitedText,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryLightest: Color.lerp(primaryLightest, other.primaryLightest, t)!,
      primaryGhost: Color.lerp(primaryGhost, other.primaryGhost, t)!,
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
      surfaceRecessed: Color.lerp(surfaceRecessed, other.surfaceRecessed, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      disabledSurface: Color.lerp(disabledSurface, other.disabledSurface, t)!,
      disabledOnSurface: Color.lerp(
        disabledOnSurface,
        other.disabledOnSurface,
        t,
      )!,
      knobFill: Color.lerp(knobFill, other.knobFill, t)!,
      toggleTrackOn: Color.lerp(toggleTrackOn, other.toggleTrackOn, t)!,
      toggleTrackOff: Color.lerp(toggleTrackOff, other.toggleTrackOff, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentPurpleTile: Color.lerp(
        accentPurpleTile,
        other.accentPurpleTile,
        t,
      )!,
      accentPeriwinkle: Color.lerp(
        accentPeriwinkle,
        other.accentPeriwinkle,
        t,
      )!,
      accentPeriwinkleTile: Color.lerp(
        accentPeriwinkleTile,
        other.accentPeriwinkleTile,
        t,
      )!,
      accentPeriwinkleChip: Color.lerp(
        accentPeriwinkleChip,
        other.accentPeriwinkleChip,
        t,
      )!,
      accentButter: Color.lerp(accentButter, other.accentButter, t)!,
      accentButterTile: Color.lerp(
        accentButterTile,
        other.accentButterTile,
        t,
      )!,
      accentButterCream: Color.lerp(
        accentButterCream,
        other.accentButterCream,
        t,
      )!,
      accentBlush: Color.lerp(accentBlush, other.accentBlush, t)!,
      accentBlushTile: Color.lerp(accentBlushTile, other.accentBlushTile, t)!,
      accentMint: Color.lerp(accentMint, other.accentMint, t)!,
      accentMintTile: Color.lerp(accentMintTile, other.accentMintTile, t)!,
      statusNormalBg: Color.lerp(statusNormalBg, other.statusNormalBg, t)!,
      statusNormalDot: Color.lerp(statusNormalDot, other.statusNormalDot, t)!,
      statusNormalText: Color.lerp(
        statusNormalText,
        other.statusNormalText,
        t,
      )!,
      statusElevatedBg: Color.lerp(
        statusElevatedBg,
        other.statusElevatedBg,
        t,
      )!,
      statusElevatedDot: Color.lerp(
        statusElevatedDot,
        other.statusElevatedDot,
        t,
      )!,
      statusElevatedText: Color.lerp(
        statusElevatedText,
        other.statusElevatedText,
        t,
      )!,
      statusAlertBg: Color.lerp(statusAlertBg, other.statusAlertBg, t)!,
      statusAlertDot: Color.lerp(statusAlertDot, other.statusAlertDot, t)!,
      statusAlertText: Color.lerp(statusAlertText, other.statusAlertText, t)!,
      statusActiveBg: Color.lerp(statusActiveBg, other.statusActiveBg, t)!,
      statusActiveDot: Color.lerp(statusActiveDot, other.statusActiveDot, t)!,
      statusActiveText: Color.lerp(
        statusActiveText,
        other.statusActiveText,
        t,
      )!,
      statusInvitedBg: Color.lerp(statusInvitedBg, other.statusInvitedBg, t)!,
      statusInvitedText: Color.lerp(
        statusInvitedText,
        other.statusInvitedText,
        t,
      )!,
    );
  }
}
