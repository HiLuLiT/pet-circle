import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Figma Design Tokens — all 9 primitive colors from the Figma variables.
// EVERY color in the app MUST reference one of these.
// ═══════════════════════════════════════════════════════════════════════════════

class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF8F1E7);
  static const lightYellow = Color(0xFFFFECB7);
  static const chocolate = Color(0xFF402A24);
  static const pink = Color(0xFFFFC2B5);
  static const cherry = Color(0xFFE64E60);
  static const lightBlue = Color(0xFF75ACFF);
  static const blue = Color(0xFF146FD9);
  static const black = Color(0xFF000000);

  // ── Backward-compatibility aliases (deprecated — migrate away) ──
  @Deprecated('Use AppColors.chocolate instead')
  static const burgundy = chocolate;
  @Deprecated('Use AppColors.chocolate instead')
  static const textPrimary = chocolate;
  @Deprecated('Use AppColors.chocolate instead')
  static const textMuted = chocolate;
  @Deprecated('Use AppColors.lightBlue instead')
  static const accentBlue = lightBlue;
  @Deprecated('Use AppColors.lightBlue instead')
  static const successGreen = lightBlue;
  @Deprecated('Use AppColors.cherry instead')
  static const warningAmber = cherry;
}

class AppRadii {
  static const small = Radius.circular(12);
  static const medium = Radius.circular(16);
  static const large = Radius.circular(20);
  static const pill = Radius.circular(999);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.chocolate,
    height: 1.2,
  );
  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.chocolate,
    height: 1.2,
  );
  static const heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.chocolate,
    height: 1.2,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.chocolate,
    height: 1.4,
  );
  static const bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.chocolate, // use with .copyWith(color: AppColors.chocolate.withValues(alpha: 0.5)) where needed
    height: 1.4,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.chocolate, // use with reduced opacity where muted
    height: 1.2,
  );
  static const badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );
}

class AppShadows {
  static final neumorphicOuter = [
    BoxShadow(
      color: AppColors.lightBlue.withValues(alpha: 0.2),
      offset: const Offset(6, 6),
      blurRadius: 12,
    ),
    BoxShadow(
      color: AppColors.white.withValues(alpha: 0.8),
      offset: const Offset(-6, -6),
      blurRadius: 12,
    ),
  ];

  static final neumorphicInner = [
    BoxShadow(
      color: AppColors.lightBlue.withValues(alpha: 0.2),
      offset: const Offset(6, 6),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: AppColors.white.withValues(alpha: 0.8),
      offset: const Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════════
// Dark mode palette — maps each Figma token to a dark-appropriate value.
// ═══════════════════════════════════════════════════════════════════════════════

class AppColorsDark {
  static const white = Color(0xFF1A1A1A);       // dark surface
  static const offWhite = Color(0xFF2A2420);     // dark card
  static const lightYellow = Color(0xFF3D3520);  // muted yellow
  static const chocolate = Color(0xFFF5E6E0);    // light text on dark
  static const pink = Color(0xFF5C3A34);         // muted pink
  static const cherry = Color(0xFFE64E60);       // stays vivid for alerts
  static const lightBlue = Color(0xFF4A7AB8);    // slightly muted
  static const blue = Color(0xFF5B9AE8);         // brighter for dark bg
  static const black = Color(0xFFFFFFFF);        // inverted
}

ThemeData buildAppTheme() {
  final baseTextTheme = GoogleFonts.interTextTheme();
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.pink,
      primary: AppColors.chocolate,
      surface: AppColors.white,
    ),
    textTheme: baseTextTheme.copyWith(
      headlineSmall: AppTextStyles.heading2,
      titleLarge: AppTextStyles.heading3,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.bodyMuted,
      labelSmall: AppTextStyles.caption,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(AppRadii.pill),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColorsDark.pink,
      brightness: Brightness.dark,
      primary: AppColorsDark.chocolate,
      surface: AppColorsDark.white,
    ),
    textTheme: baseTextTheme.copyWith(
      headlineSmall: AppTextStyles.heading2.copyWith(color: AppColorsDark.chocolate),
      titleLarge: AppTextStyles.heading3.copyWith(color: AppColorsDark.chocolate),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColorsDark.chocolate),
      bodySmall: AppTextStyles.bodyMuted.copyWith(color: AppColorsDark.chocolate),
      labelSmall: AppTextStyles.caption.copyWith(color: AppColorsDark.chocolate),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.offWhite,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(AppRadii.pill),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
