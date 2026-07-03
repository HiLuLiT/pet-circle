import 'package:flutter/material.dart';

/// Spacing tokens.
///
/// Pet Circle v3 (Claude-Design) scale lives under the `pc*` prefix.
/// Legacy v2 names are kept for backward compatibility.
class AppSpacingTokens {
  AppSpacingTokens._();

  // ── PC v3 scale ──────────────────────────────────────────────────────────
  static const double pcXs = 6;
  static const double pcSm = 10;
  static const double pcMd = 14;
  static const double pcLg = 18;
  static const double pcXl = 24;

  // ── Legacy v2 scale ──────────────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Border-radius tokens.
///
/// Pet Circle v3 semantic radii live under the `pc*` prefix.
class AppRadiiTokens {
  AppRadiiTokens._();

  // ── PC v3: semantic radii ────────────────────────────────────────────────
  /// Field (inputs, selects, chips) — 12, per Figma DS node 402-1191.
  static const double pcField = 12;

  /// Card — 16, per Figma DS node 402-1191.
  static const double pcCard = 16;

  /// Tile (large rounded surfaces) — 30
  static const double pcTile = 30;

  /// Pill (fully rounded) — sentinel; use [BorderRadius.circular(pcPill)]
  /// or [borderRadiusPill].
  static const double pcPill = 9999;

  // ── Legacy v2 numeric scale ──────────────────────────────────────────────
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

  // ── PC v3 BorderRadius getters ───────────────────────────────────────────
  static BorderRadius get borderRadiusField => BorderRadius.circular(pcField);
  static BorderRadius get borderRadiusCard => BorderRadius.circular(pcCard);
  static BorderRadius get borderRadiusTile => BorderRadius.circular(pcTile);
  static BorderRadius get borderRadiusPill => BorderRadius.circular(pcPill);
}
