import 'package:flutter/material.dart';

/// Primitive color tokens from the v2 design system.
///
/// Every color in the app should reference one of these constants.
/// Semantic mapping lives in [AppSemanticColors].
class AppPrimitives {
  AppPrimitives._();

  // ── Ink (Text / UI) ──────────────────────────────────────────────────────
  static const Color inkLighter = Color(0xFF72777A);
  static const Color inkLight = Color(0xFF6C7072);
  static const Color inkBase = Color(0xFF404446);
  static const Color inkDark = Color(0xFF303437);
  static const Color inkDarker = Color(0xFF202325);
  static const Color inkDarkest = Color(0xFF090A0A);

  // ── Sky (Backgrounds / Borders) ──────────────────────────────────────────
  static const Color skyWhite = Color(0xFFFFFFFF);
  static const Color skyLightest = Color(0xFFF7F9FA);
  static const Color skyLighter = Color(0xFFF2F4F5);
  static const Color skyLight = Color(0xFFE3E5E5);
  static const Color skyBase = Color(0xFFCDCFD0);
  static const Color skyDark = Color(0xFF979C9E);

  // ── Primary / Brand (Purple) ─────────────────────────────────────────────
  static const Color primaryLightest = Color(0xFFE7E7FF);
  static const Color primaryLighter = Color(0xFFC6C4FF);
  static const Color primaryLight = Color(0xFF9990FF);
  static const Color primaryBase = Color(0xFF6B4EFF);
  static const Color primaryDark = Color(0xFF5538EE);

  // ── Red (Error / Danger) ─────────────────────────────────────────────────
  static const Color redLightest = Color(0xFFFFE5E5);
  static const Color redLighter = Color(0xFFFF9898);
  static const Color redLight = Color(0xFFFF6D6D);
  static const Color redBase = Color(0xFFFF5247);
  static const Color redDarkest = Color(0xFFD3180C);

  // ── Green (Success) ──────────────────────────────────────────────────────
  static const Color greenLightest = Color(0xFFECFCE5);
  static const Color greenLighter = Color(0xFF7DDE86);
  static const Color greenLight = Color(0xFF4CD471);
  static const Color greenBase = Color(0xFF23C16B);
  static const Color greenDarkest = Color(0xFF198155);

  // ── Yellow (Warning) ─────────────────────────────────────────────────────
  static const Color yellowLightest = Color(0xFFFFEFD7);
  static const Color yellowLighter = Color(0xFFFFD188);
  static const Color yellowLight = Color(0xFFFFC462);
  static const Color yellowBase = Color(0xFFFFB323);
  static const Color yellowDarkest = Color(0xFFA05E03);

  // ── Blue (Info) ──────────────────────────────────────────────────────────
  static const Color blueLightest = Color(0xFFC9F0FF);
  static const Color blueLighter = Color(0xFF9BDCFD);
  static const Color blueLight = Color(0xFF6EC2FB);
  static const Color blueBase = Color(0xFF48A7F8);
  static const Color blueDarkest = Color(0xFF0065D0);

  // ── Social / 3rd Party ───────────────────────────────────────────────────
  static const Color facebookBase = Color(0xFF0078FF);
  static const Color facebookDark = Color(0xFF0067DB);
  static const Color twitterBase = Color(0xFF1DA1F2);
  static const Color twitterDark = Color(0xFF0C90E1);
}
