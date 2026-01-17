import 'package:flutter/material.dart';

class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF8F1E7);
  static const pink = Color(0xFFF0AFFF);
  static const burgundy = Color(0xFF440206);
  static const textPrimary = Color(0xFF2C3E50);
  static const textMuted = Color(0xFF6B7C8E);
  static const accentBlue = Color(0xFF5B9BD5);
  static const successGreen = Color(0xFF7FBA7A);
  static const warningAmber = Color(0xFFF39C12);
  static const lightYellow = Color(0xFFFFECB7);
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
    color: AppColors.burgundy,
    height: 1.2,
  );
  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.burgundy,
    height: 1.2,
  );
  static const heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.burgundy,
    height: 1.2,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.burgundy,
    height: 1.4,
  );
  static const bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
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
  static const neumorphicOuter = [
    BoxShadow(
      color: Color(0x335B9BD5),
      offset: Offset(6, 6),
      blurRadius: 12,
    ),
    BoxShadow(
      color: Color(0xCCFFFFFF),
      offset: Offset(-6, -6),
      blurRadius: 12,
    ),
  ];

  static const neumorphicInner = [
    BoxShadow(
      color: Color(0x335B9BD5),
      offset: Offset(6, 6),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0xCCFFFFFF),
      offset: Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.white,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.pink,
      primary: AppColors.burgundy,
      surface: AppColors.white,
      background: AppColors.white,
    ),
    textTheme: const TextTheme(
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
