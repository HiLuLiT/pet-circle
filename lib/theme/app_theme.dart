import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Theme builders — wire design tokens into Flutter ThemeData.
// As of Pet Circle v3 (Claude-Design palette), the light theme uses pcBg/pcPurple.
// ═══════════════════════════════════════════════════════════════════════════════

/// Returns the Instrument Sans text theme, falling back to the default text
/// theme when the font is unavailable offline.
TextTheme _instrumentSansTextTheme([TextTheme? base]) {
  try {
    return base != null
        ? GoogleFonts.instrumentSansTextTheme(base)
        : GoogleFonts.instrumentSansTextTheme();
  } catch (_) {
    return base ?? const TextTheme();
  }
}

ThemeData buildAppTheme() {
  final baseTextTheme = _instrumentSansTextTheme();
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPrimitives.pcBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPrimitives.pcPurple,
      primary: AppPrimitives.pcPurple,
      surface: AppPrimitives.pcSurface,
    ),
    textTheme: baseTextTheme.copyWith(
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
  final baseTextTheme = _instrumentSansTextTheme(ThemeData.dark().textTheme);
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPrimitives.pcDarkBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPrimitives.pcPurple,
      brightness: Brightness.dark,
      primary: AppPrimitives.pcPurpleTile,
      surface: AppPrimitives.pcDarkSurface,
    ),
    textTheme: baseTextTheme.copyWith(
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
