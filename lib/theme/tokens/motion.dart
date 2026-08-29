import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Spring-based motion tokens for gesture/state-driven micro-interactions.
///
/// Translates the Apple "Designing Fluid Interfaces" spring model
/// (`.claude/skills/apple-design/SKILL.md`) into Flutter's
/// `package:flutter/physics.dart` primitives: a [SpringDescription] built
/// from a *damping ratio* + *response* (Apple's designer-facing pair)
/// rather than the raw mass/stiffness/damping triplet, driven by an
/// [AnimationController] via [SpringSimulation].
///
/// Springs animate from whatever value is currently on screen (start the
/// simulation from the controller's live `.value`, never a hard-coded
/// constant), so a second state change before the first settles is
/// naturally continuous — unlike a fixed `Duration`/`Curve` animation, which
/// restarts flat from its declared begin value.
class AppMotionTokens {
  AppMotionTokens._();

  /// Damping ratio for a critically-damped, non-bouncy settle — the default
  /// for any UI transition the user didn't just throw or flick (skill Quick
  /// Reference: "Default UI spring").
  static const double criticalDamping = 1.0;

  /// Response (seconds) for the default, non-momentum settle — toggle
  /// knobs, segmented indicators, and similar state-driven repositioning.
  static const double defaultResponse = 0.3;

  /// Builds a [SpringDescription] from Apple's designer-facing parameters.
  ///
  /// `damping` is the damping ratio (`1.0` = critically damped, no
  /// overshoot; `< 1.0` = bouncier) and `response` is the time constant in
  /// seconds — not a fixed duration, since a spring's settle time emerges
  /// from its parameters rather than being declared.
  ///
  /// Conversion matches SwiftUI's `.spring(response:dampingFraction:)`
  /// (mass fixed at 1): `stiffness = (2π/response)²`,
  /// `damping = 4π·ratio/response`.
  static SpringDescription spring({
    double damping = criticalDamping,
    double response = defaultResponse,
  }) {
    final double angularFrequency = 2 * math.pi / response;
    return SpringDescription(
      mass: 1,
      stiffness: angularFrequency * angularFrequency,
      damping: 4 * math.pi * damping / response,
    );
  }

  /// A [SpringSimulation] that animates from [start] to [end], optionally
  /// carrying an initial [velocity] (skill §5 — velocity handoff avoids a
  /// visible seam when a gesture hands off into a settle).
  static SpringSimulation simulation({
    required double start,
    required double end,
    double velocity = 0,
    double damping = criticalDamping,
    double response = defaultResponse,
  }) {
    return SpringSimulation(
      spring(damping: damping, response: response),
      start,
      end,
      velocity,
    );
  }

  /// True when the platform requests reduced motion (skill §14, Flutter's
  /// equivalent of `prefers-reduced-motion`). Callers should skip springs
  /// and jump straight to the end state rather than skip feedback entirely.
  static bool reducedMotionOf(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
