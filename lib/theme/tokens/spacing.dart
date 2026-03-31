import 'package:flutter/material.dart';

/// Spacing tokens from the v2 design system.
class AppSpacingTokens {
  AppSpacingTokens._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Border-radius tokens from the v2 design system.
class AppRadiiTokens {
  AppRadiiTokens._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 16;
  static const double xl = 48;
  static const double full = 1000;

  // ── Convenience BorderRadius getters ─────────────────────────────────────
  static BorderRadius get borderRadiusSm => BorderRadius.circular(sm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(md);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(lg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(xl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(full);
}
