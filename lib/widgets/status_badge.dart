import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/theme/tokens/typography.dart';

/// Visual status family for [StatusBadge].
///
/// Mirrors the React `StatusChip` `Status` type from the PC v3 design system:
///   * [normal]   — periwinkle family (info / "Normal")
///   * [elevated] — butter family    (warning / "Elevated")
///   * [alert]    — blush family     (danger  / "Alert")
///   * [active]   — mint family      (success / "Active") — *no dot*
///   * [invited]  — yellow family    (pending / "Invited") — *no dot*
enum StatusBadgeStatus { normal, elevated, alert, active, invited }

/// Pill-shaped status chip — Pet Circle v3 / Claude-Design palette.
///
/// Public API is kept backward-compatible with the pre-v3 widget:
///   ```dart
///   StatusBadge(label: 'Normal', color: pet.statusColor)
///   ```
///
/// The legacy `color` parameter is **no longer used as a literal background**.
/// Instead, the widget infers a [StatusBadgeStatus] from the color (matching
/// PC primitives) and pulls the correct bg/dot/text triplet from
/// [AppSemanticColors]. To force a status explicitly, pass [status] — it
/// takes precedence over `color`.
///
/// Color → status inference rules:
///   * red family   (`redBase`, `pcBlush`, `*Bg/*Dot/*Text` alert tokens)        → [alert]
///   * yellow/butter family                                                       → [elevated]
///   * green/mint/primary (success-ish) family                                    → [active]
///   * anything else (blue/periwinkle/purple/unknown) — falls back to            → [normal]
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.status,
  });

  /// Display text inside the pill.
  final String label;

  /// Legacy color hint — kept for API compatibility. Used to derive
  /// [status] when [status] is not provided. Ignored when [status] is set.
  final Color? color;

  /// Explicit status family. When provided, overrides any inference from
  /// [color]. New call-sites should prefer this.
  final StatusBadgeStatus? status;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final effectiveStatus = status ?? _inferStatus(color);

    final bg = _bgFor(c, effectiveStatus);
    final dot = _dotFor(c, effectiveStatus);
    final text = _textFor(c, effectiveStatus);

    final textStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.0,
      color: text,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // No dot for the "active" / "invited" variants — matches React
          // StatusChip / Pills "Invited".
          if (_hasDot(effectiveStatus)) ...[
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(label, style: textStyle),
        ],
      ),
    );
  }

  // ── Dot visibility ───────────────────────────────────────────────────────

  /// Whether this variant renders a leading dot. The [active] and [invited]
  /// variants are dot-less (matching the React StatusChip / Pills "Invited").
  static bool _hasDot(StatusBadgeStatus s) =>
      s != StatusBadgeStatus.active && s != StatusBadgeStatus.invited;

  // ── Status inference ─────────────────────────────────────────────────────

  static StatusBadgeStatus _inferStatus(Color? color) {
    if (color == null) return StatusBadgeStatus.normal;
    // Alert / danger family.
    if (_matchesAny(color, const [
      AppPrimitives.redBase,
      AppPrimitives.pcBlush,
      AppPrimitives.pcBlushTile,
      AppPrimitives.pcStatusAlertBg,
      AppPrimitives.pcStatusAlertDot,
      AppPrimitives.pcStatusAlertText,
    ])) {
      return StatusBadgeStatus.alert;
    }
    // Elevated / warning family.
    if (_matchesAny(color, const [
      AppPrimitives.yellowLightest,
      AppPrimitives.pcButter,
      AppPrimitives.pcButterTile,
      AppPrimitives.pcStatusElevatedBg,
      AppPrimitives.pcStatusElevatedDot,
      AppPrimitives.pcStatusElevatedText,
    ])) {
      return StatusBadgeStatus.elevated;
    }
    // Active / success family.
    if (_matchesAny(color, const [
      AppPrimitives.greenBase,
      AppPrimitives.primaryBase,
      AppPrimitives.pcMint,
      AppPrimitives.pcMintTile,
      AppPrimitives.pcPurple,
      AppPrimitives.pcStatusActiveBg,
      AppPrimitives.pcStatusActiveDot,
      AppPrimitives.pcStatusActiveText,
    ])) {
      return StatusBadgeStatus.active;
    }
    // Default — periwinkle "normal" pill.
    return StatusBadgeStatus.normal;
  }

  static bool _matchesAny(Color c, List<Color> options) {
    final v = c.toARGB32();
    for (final o in options) {
      if (o.toARGB32() == v) return true;
    }
    return false;
  }

  // ── Semantic color pickers ───────────────────────────────────────────────

  static Color _bgFor(AppSemanticColors c, StatusBadgeStatus s) {
    switch (s) {
      case StatusBadgeStatus.normal:
        return c.statusNormalBg;
      case StatusBadgeStatus.elevated:
        return c.statusElevatedBg;
      case StatusBadgeStatus.alert:
        return c.statusAlertBg;
      case StatusBadgeStatus.active:
        return c.statusActiveBg;
      case StatusBadgeStatus.invited:
        return c.statusInvitedBg;
    }
  }

  static Color _dotFor(AppSemanticColors c, StatusBadgeStatus s) {
    switch (s) {
      case StatusBadgeStatus.normal:
        return c.statusNormalDot;
      case StatusBadgeStatus.elevated:
        return c.statusElevatedDot;
      case StatusBadgeStatus.alert:
        return c.statusAlertDot;
      case StatusBadgeStatus.active:
        return c.statusActiveDot;
      case StatusBadgeStatus.invited:
        // Invited has no dot; this is never rendered. Reuse the active dot to
        // keep the switch exhaustive.
        return c.statusActiveDot;
    }
  }

  static Color _textFor(AppSemanticColors c, StatusBadgeStatus s) {
    switch (s) {
      case StatusBadgeStatus.normal:
        return c.statusNormalText;
      case StatusBadgeStatus.elevated:
        return c.statusElevatedText;
      case StatusBadgeStatus.alert:
        return c.statusAlertText;
      case StatusBadgeStatus.active:
        return c.statusActiveText;
      case StatusBadgeStatus.invited:
        return c.statusInvitedText;
    }
  }
}
