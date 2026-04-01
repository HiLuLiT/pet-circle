import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Theme builders — wire design tokens into Flutter ThemeData.
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
    scaffoldBackgroundColor: AppPrimitives.skyWhite,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPrimitives.primaryBase,
      primary: AppPrimitives.primaryBase,
      surface: AppPrimitives.skyWhite,
    ),
    textTheme: baseTextTheme.copyWith(
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppPrimitives.inkDarkest,
        height: 32 / 24,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppPrimitives.inkDarkest,
        height: 1.0,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.inkBase,
        height: 24 / 16,
      ),
      bodySmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.inkLight,
        height: 24 / 16,
      ),
      labelSmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppPrimitives.inkBase,
        height: 1.0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPrimitives.skyLighter,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
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
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPrimitives.primaryBase,
      brightness: Brightness.dark,
      primary: AppPrimitives.primaryBase,
      surface: const Color(0xFF1A1A1A),
    ),
    textTheme: baseTextTheme.copyWith(
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF5E6E0),
        height: 32 / 24,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF5E6E0),
        height: 1.0,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFFF5E6E0),
        height: 24 / 16,
      ),
      bodySmall: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFFB0B0B0),
        height: 24 / 16,
      ),
      labelSmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xFFF5E6E0),
        height: 1.0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2420),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    extensions: const [AppSemanticColors.dark],
  );
}
