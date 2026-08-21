import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/theme/tokens/typography.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Theme builders — wire design tokens into Flutter ThemeData.
// As of Pet Circle v3 (Claude-Design palette), the light theme uses pcBg/pcPurple.
// ═══════════════════════════════════════════════════════════════════════════════
//
// fontFamily is set directly to the locally-bundled "Instrument Sans" (see
// pubspec.yaml, which registers all 4 static weights). Do NOT reintroduce
// google_fonts here — GoogleFonts.instrumentSansTextTheme() fetches the same
// family name from Google's CDN and registers it under the identical
// "Instrument Sans" string as the local assets, which causes Skia's font
// manager (esp. on Flutter Web) to resolve some weight requests to the wrong
// font source, making bold text intermittently render lighter than 700.

ThemeData buildAppTheme() {
  return ThemeData(
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPrimitives.pcBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPrimitives.pcPurple,
      primary: AppPrimitives.pcPurple,
      surface: AppPrimitives.pcSurface,
    ),
    textTheme: ThemeData.light().textTheme.copyWith(
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppPrimitives.pcInk,
        height: 32 / 24,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppPrimitives.pcInk,
        height: 1.0,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcInk,
        height: 24 / 16,
      ),
      bodySmall: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcInkSecondary,
        height: 24 / 16,
      ),
      labelSmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcInkSecondary,
        height: 1.0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPrimitives.pcRecessed,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: AppRadiiTokens.borderRadiusField,
        borderSide: BorderSide.none,
      ),
    ),
    extensions: const [AppSemanticColors.light],
  );
}

ThemeData buildDarkTheme() {
  // Every colour here comes from the same `pcDark*` set that
  // AppSemanticColors.dark uses. Previously this builder painted from one
  // palette while every widget read AppSemanticColors.dark from another, so the
  // designed warm tokens never actually rendered anywhere.
  const c = AppSemanticColors.dark;

  return ThemeData(
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: c.background,
    // Spelled out rather than ColorScheme.fromSeed: the seeded version left
    // ~20 slots (outline, surfaceContainer*, secondary, ...) to M3's tonal
    // generator, which produced cool violet-tinted greys that fought the warm
    // palette wherever a stock Material widget read them.
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppPrimitives.pcDarkPurple,
      onPrimary: AppPrimitives.pcDarkCanvas,
      primaryContainer: AppPrimitives.pcDarkPurpleWash,
      onPrimaryContainer: AppPrimitives.pcPurpleTile,
      secondary: AppPrimitives.pcDarkPeriwinkle,
      onSecondary: AppPrimitives.pcDarkCanvas,
      secondaryContainer: AppPrimitives.pcDarkPeriwinkleTile,
      onSecondaryContainer: AppPrimitives.pcDarkStatusNormalText,
      tertiary: AppPrimitives.pcDarkMint,
      onTertiary: AppPrimitives.pcDarkCanvas,
      tertiaryContainer: AppPrimitives.pcDarkMintTile,
      onTertiaryContainer: AppPrimitives.pcDarkStatusActiveText,
      error: AppPrimitives.pcDarkBlush,
      onError: AppPrimitives.pcDarkCanvas,
      errorContainer: AppPrimitives.pcDarkBlushTile,
      onErrorContainer: AppPrimitives.pcDarkStatusAlertText,
      surface: AppPrimitives.pcDarkSurface,
      onSurface: AppPrimitives.pcDarkInk,
      onSurfaceVariant: AppPrimitives.pcDarkInkSecondary,
      surfaceContainerLowest: AppPrimitives.pcDarkCanvas,
      surfaceContainerLow: AppPrimitives.pcDarkWell,
      surfaceContainer: AppPrimitives.pcDarkSurface,
      surfaceContainerHigh: AppPrimitives.pcDarkElevated,
      surfaceContainerHighest: AppPrimitives.pcDarkElevated,
      surfaceDim: AppPrimitives.pcDarkCanvas,
      surfaceBright: AppPrimitives.pcDarkElevated,
      inverseSurface: AppPrimitives.pcDarkInk,
      onInverseSurface: AppPrimitives.pcDarkCanvas,
      outline: AppPrimitives.pcDarkDivider,
      outlineVariant: AppPrimitives.pcDarkHairline,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    ),
    dividerColor: c.divider,
    cardColor: c.surface,
    canvasColor: c.background,
    hintColor: c.textTertiary,
    disabledColor: c.disabled,
    iconTheme: const IconThemeData(color: AppPrimitives.pcDarkInkSecondary),
    primaryIconTheme: const IconThemeData(color: AppPrimitives.pcDarkInk),
    textTheme: ThemeData.dark().textTheme.copyWith(
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppPrimitives.pcDarkInk,
        height: 32 / 24,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppPrimitives.pcDarkInk,
        height: 1.0,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcDarkInk,
        height: 24 / 16,
      ),
      bodySmall: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcDarkInkSecondary,
        height: 24 / 16,
      ),
      labelSmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcDarkInkSecondary,
        height: 1.0,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPrimitives.pcDarkCanvas,
      foregroundColor: AppPrimitives.pcDarkInk,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadiiTokens.borderRadiusCard,
      ),
    ),
    dialogTheme: DialogThemeData(
      // One step up the ladder from `surface`: a dialog floats above cards, and
      // on a dark canvas that has to be said with lightness, not shadow.
      backgroundColor: AppPrimitives.pcDarkElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadiiTokens.borderRadiusCard,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppPrimitives.pcDarkElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPrimitives.pcDarkElevated,
      contentTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcDarkInk,
        height: 24 / 16,
      ),
      actionTextColor: AppPrimitives.pcDarkPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadiiTokens.borderRadiusField,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPrimitives.pcDarkSurface,
      selectedItemColor: AppPrimitives.pcDarkInk,
      unselectedItemColor: AppPrimitives.pcDarkInkTertiary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceRecessed,
      hintStyle: const TextStyle(color: AppPrimitives.pcDarkInkTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: AppRadiiTokens.borderRadiusField,
        borderSide: BorderSide.none,
      ),
    ),
    extensions: const [AppSemanticColors.dark],
  );
}
