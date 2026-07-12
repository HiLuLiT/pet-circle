import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    extensions: const [AppSemanticColors.light],
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPrimitives.pcDarkBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPrimitives.pcPurple,
      brightness: Brightness.dark,
      primary: AppPrimitives.pcPurpleTile,
      surface: AppPrimitives.pcDarkSurface,
    ),
    textTheme: ThemeData.dark().textTheme.copyWith(
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppPrimitives.pcDarkOnSurface,
        height: 32 / 24,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppPrimitives.pcDarkOnSurface,
        height: 1.0,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcDarkOnSurface,
        height: 24 / 16,
      ),
      bodySmall: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcDarkOnSurfaceMuted,
        height: 24 / 16,
      ),
      labelSmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.pcDarkOnSurface,
        height: 1.0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPrimitives.pcDarkRecessed,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    extensions: const [AppSemanticColors.dark],
  );
}
