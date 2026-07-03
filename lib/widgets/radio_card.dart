import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// A selectable card with a leading radio dot, a title, an optional
/// description, and an optional trailing badge.
///
/// Matches the React `RadioCard.tsx` component from the Pet Circle v3
/// (Claude-Design) palette:
///   - Full width, padding 18, radius 18, surface (white) background
///   - When [selected] is true: inset 2px purple border (ring) and a
///     filled 12×12 purple inner dot
///   - When unselected: 2px hairline-grey ring with an empty inner dot
///   - Optional [badge] renders as a small pill with mint-tile background
///     and active-status text color
///
/// All colors come from [AppSemanticColors] / [AppSemanticTextStyles] —
/// no hex values are hardcoded here.
class RadioCard extends StatelessWidget {
  const RadioCard({
    super.key,
    required this.title,
    this.description,
    this.badge,
    this.selected = false,
    this.onTap,
  });

  /// Main label, rendered bold at 17px.
  final String title;

  /// Optional secondary line below the title, rendered at 13.5px in
  /// [AppSemanticColors.textSecondary].
  final String? description;

  /// Optional trailing pill label.
  final String? badge;

  /// When true, draws a 2px purple ring around the card and fills the
  /// inner radio dot.
  final bool selected;

  /// Tap callback. When null, the card is non-interactive.
  final VoidCallback? onTap;

  // ── Layout constants ─────────────────────────────────────────────────────
  static const double _outerDotSize = 24;
  static const double _innerDotSize = 12;
  static const double _ringWidth = 2;
  static const double _rowGap = 14;
  static const double _titleFontSize = 17;
  static const double _descriptionFontSize = 13.5;
  static const double _badgeFontSize = 12;
  static const double _descriptionTopGap = 2;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);
    final radius = BorderRadius.circular(AppRadiiTokens.pcCard);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: radius,
            border: selected
                ? Border.all(color: colors.accentPurple, width: _ringWidth)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: _rowGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppSemanticTextStyles.pcBodyBold.copyWith(
                        fontSize: _titleFontSize,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: _descriptionTopGap),
                      Text(
                        description!,
                        style: AppSemanticTextStyles.pcBodyMuted.copyWith(
                          fontSize: _descriptionFontSize,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: _rowGap),
                _Badge(label: badge!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Leading radio indicator: 24×24 outer ring with an optional 12×12 inner
/// filled dot when [selected].
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);
    final ringColor =
        selected ? colors.accentPurple : colors.hairline;

    return Container(
      width: RadioCard._outerDotSize,
      height: RadioCard._outerDotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: RadioCard._ringWidth),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: RadioCard._innerDotSize,
              height: RadioCard._innerDotSize,
              decoration: BoxDecoration(
                color: colors.accentPurple,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

/// Trailing pill badge: mint-tile background, active-status text color,
/// bold 12px, padded 6×12, fully rounded.
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.accentMintTile,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: AppSemanticTextStyles.pcLabelBold.copyWith(
          fontSize: RadioCard._badgeFontSize,
          color: colors.statusActiveText,
          height: 1.0,
        ),
      ),
    );
  }
}
