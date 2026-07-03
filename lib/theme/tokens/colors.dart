import 'package:flutter/material.dart';

/// Primitive color tokens.
///
/// Two palettes live here:
/// 1. **Pet Circle v3** (Claude-Design palette) — the current design language.
///    Use the `pc*` prefixed primitives below for new code.
/// 2. **Legacy v2** — kept for backward compatibility with widgets/screens that
///    haven't migrated yet. Will be removed once all usages are gone.
///
/// Every color in the app should reference one of these constants.
/// Semantic mapping lives in [AppSemanticColors].
class AppPrimitives {
  AppPrimitives._();

  // ── PC v3: Ink (Text) ────────────────────────────────────────────────────
  static const Color pcInk = Color(0xFF161616);
  static const Color pcInkSecondary = Color(0xFF595959);
  static const Color pcInkTertiary = Color(0xFF9A9A9A);

  // ── PC v3: Surfaces ──────────────────────────────────────────────────────
  // Neutrals/Background per Figma DS node 402-1191.
  static const Color pcBg = Color(0xFFF5F3EF);
  static const Color pcSurface = Color(0xFFFFFFFF);
  static const Color pcRecessed = Color(0xFFEFEBE1);
  static const Color pcHairline = Color(0xFFECE7DD);

  // ── PC v3: Brand (Purple) ────────────────────────────────────────────────
  static const Color pcPurple = Color(0xFF7E5CE0);
  static const Color pcPurpleTile = Color(0xFFC3AEF0);
  // Candy/Purple/Ghost — pale wash for avatar tiles / icon backdrops.
  static const Color pcPurpleGhost = Color(0xFFE7E7FF);

  // ── PC v3: Accents ───────────────────────────────────────────────────────
  static const Color pcPeriwinkle = Color(0xFF6485DB);
  static const Color pcPeriwinkleTile = Color(0xFFD2DCF5);
  static const Color pcPeriwinkleChip = Color(0xFFCDD8F5);

  static const Color pcButter = Color(0xFFD98E40);
  static const Color pcButterTile = Color(0xFFF0EC93);
  // Candy/Butter/Cream — warm cream tile (#E8E4D8). Distinct from the bright
  // yellow [pcButterTile]; used for the toggle off-track and note callouts.
  static const Color pcButterCream = Color(0xFFE8E4D8);
  // Candy/Butter/Light and /Dark per Figma DS node 402-1191.
  static const Color pcButterLight = Color(0xFFFFEFD7);
  static const Color pcButterDark = Color(0xFFA05E03);

  static const Color pcBlush = Color(0xFFDD6593);
  // Candy/Blush/Tile per Figma DS node 402-1191.
  static const Color pcBlushTile = Color(0xFFFCE4EC);

  static const Color pcMint = Color(0xFF46A05F);
  static const Color pcMintTile = Color(0xFFC2E8C8);

  // Candy/Tomato/Accent per Figma DS node 402-1191.
  static const Color pcTomato = Color(0xFFF0634F);

  // ── PC v3: Status — Normal (periwinkle) ──────────────────────────────────
  static const Color pcStatusNormalBg = Color(0xFFECEAF7);
  static const Color pcStatusNormalDot = Color(0xFF6485DB);
  static const Color pcStatusNormalText = Color(0xFF4A56B0);

  // ── PC v3: Status — Elevated (amber) ─────────────────────────────────────
  static const Color pcStatusElevatedBg = Color(0xFFF6ECCF);
  static const Color pcStatusElevatedDot = Color(0xFFD98E40);
  static const Color pcStatusElevatedText = Color(0xFF8A6420);

  // ── PC v3: Status — Alert (blush) ────────────────────────────────────────
  static const Color pcStatusAlertBg = Color(0xFFFBE0DC);
  static const Color pcStatusAlertDot = Color(0xFFDD6593);
  static const Color pcStatusAlertText = Color(0xFFB14C77);

  // ── PC v3: Status — Active (mint) ────────────────────────────────────────
  static const Color pcStatusActiveBg = Color(0xFFD7EECB);
  static const Color pcStatusActiveDot = Color(0xFF2F6B3E);
  static const Color pcStatusActiveText = Color(0xFF2F6B3E);

  // ── PC v3: Dark-mode surfaces (warm-tinted) ──────────────────────────────
  static const Color pcDarkBg = Color(0xFF1A1A1A);
  static const Color pcDarkSurface = Color(0xFF1A1A1A);
  static const Color pcDarkRecessed = Color(0xFF2A2420);
  static const Color pcDarkOnSurface = Color(0xFFF5E6E0);
  static const Color pcDarkOnSurfaceMuted = Color(0xFFB0B0B0);

  // ═════════════════════════════════════════════════════════════════════════
  // Legacy v2 palette (kept for compatibility — do not use in new code)
  // ═════════════════════════════════════════════════════════════════════════

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
