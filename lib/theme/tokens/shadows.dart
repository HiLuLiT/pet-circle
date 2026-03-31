import 'package:flutter/material.dart';

/// Shadow tokens from the v2 design system.
///
/// Replaces the old neumorphic shadows with flat elevation levels.
class AppShadowTokens {
  AppShadowTokens._();

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0A141414),
      blurRadius: 1,
    ),
    BoxShadow(
      color: Color(0x14141414),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x14141414),
      blurRadius: 1,
    ),
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
}
