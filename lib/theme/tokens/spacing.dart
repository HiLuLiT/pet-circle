import 'package:flutter/material.dart';

/// Spacing tokens.
///
/// Pet Circle v3 (Claude-Design) scale lives under the `pc*` prefix.
/// Legacy v2 names are kept for backward compatibility.
class AppSpacingTokens {
  AppSpacingTokens._();

  // ── PC v3 scale — matches the spacing actually used in Figma ─────────────
  //
  // Measured across Figma nodes 442:6747, 407:3528, 442:8893, 442:8959 and
  // 426:1182, the design uses 4 / 8 / 12 / 16 / 20 / 24 / 28 / 32. The former
  // pc* values (6 / 10 / 14 / 18 / 24) matched only 24 — every other step
  // corresponded to nothing in the design, so code that "preferred pc*" was
  // being steered away from Figma. 12 in particular recurs (header group gap,
  // action-button gap, reminders gaps) and was absent from both old scales.
  static const double pcXs = 4;
  static const double pcSm = 8;
  static const double pcMd = 12;
  static const double pcLg = 16;
  static const double pcXl = 24;
  static const double pc2Xl = 32;

  /// One-off Figma steps that do not belong to the core rhythm: `pl-20` on the
  /// outlined button (icon-slot allowance) and `pt-28` on the "Your pets" row.
  static const double pc20 = 20;
  static const double pc28 = 28;

  // ── Legacy v2 names — aliases onto the Figma-aligned scale ───────────────
  static const double xs = pcXs; // 4
  static const double sm = pcSm; // 8
  static const double md = pcLg; // 16
  static const double lg = pcXl; // 24
  static const double xl = pc2Xl; // 32
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
