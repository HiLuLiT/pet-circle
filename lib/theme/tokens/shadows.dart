import 'package:flutter/material.dart';

/// Shadow tokens — flat elevation levels (replaced the old neumorphic pair).
///
/// The light values are near-black at 4-8% alpha. On a dark canvas that is
/// invisible: a shadow works by darkening what sits behind it, and there is
/// almost no headroom left below `pcDarkCanvas`. Material names the same
/// problem and prescribes the same two-part answer, which this palette follows:
///
///  1. **Lightness carries elevation.** The `pcDark*` surface ladder
///     (canvas -> well -> surface -> elevated) is the primary signal and does most
///     of the work. See [AppPrimitives].
///  2. **A denser shadow carries the rest.** The dark values below run 30-40%
///     alpha over a much larger blur, so a card at `pcDarkSurface` still casts a
///     readable edge onto `pcDarkCanvas` without drawing a hard seam.
///
/// Prefer the `*Of(context)` resolvers in widgets — they pick the right set for
/// the active theme. The bare [small]/[medium]/[large] lists remain the light
/// values and stay part of the public API.
class AppShadowTokens {
  AppShadowTokens._();

  // ── Light ────────────────────────────────────────────────────────────────
  static const List<BoxShadow> small = [
    BoxShadow(color: Color(0x0A141414), blurRadius: 1),
    BoxShadow(color: Color(0x14141414), blurRadius: 8),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x14141414), blurRadius: 1),
    BoxShadow(
      color: Color(0x14141414),
      offset: Offset(0, 1),
      blurRadius: 8,
      spreadRadius: 2,
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x14141414),
      offset: Offset(0, 1),
      blurRadius: 24,
      spreadRadius: 8,
    ),
  ];

  // ── Dark ─────────────────────────────────────────────────────────────────
  // Pure black rather than the light set's #141414: the shadow has to read
  // against a surface that is already dark, so the only available direction is
  // down. Alpha climbs with elevation (0x4D = 30%, 0x59 = 35%, 0x66 = 40%) and
  // the blur grows with it, keeping the edge soft instead of drawing a line.
  static const List<BoxShadow> darkSmall = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 2),
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 1), blurRadius: 12),
  ];

  static const List<BoxShadow> darkMedium = [
    BoxShadow(color: Color(0x59000000), blurRadius: 2),
    BoxShadow(
      color: Color(0x59000000),
      offset: Offset(0, 2),
      blurRadius: 14,
      spreadRadius: 2,
    ),
  ];

  static const List<BoxShadow> darkLarge = [
    BoxShadow(
      color: Color(0x66000000),
      offset: Offset(0, 2),
      blurRadius: 32,
      spreadRadius: 8,
    ),
  ];

  // ── Theme-aware resolvers ────────────────────────────────────────────────
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static List<BoxShadow> smallOf(BuildContext context) =>
      _isDark(context) ? darkSmall : small;

  static List<BoxShadow> mediumOf(BuildContext context) =>
      _isDark(context) ? darkMedium : medium;

  static List<BoxShadow> largeOf(BuildContext context) =>
      _isDark(context) ? darkLarge : large;
}
