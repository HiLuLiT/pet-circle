import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';

/// A small stat / summary card: a tinted icon tile beside a value + label.
///
/// Shared across the vet and care-circle dashboards. The icon tile colour is
/// supplied by the caller (typically a low-alpha semantic accent) so the same
/// card can convey different statuses.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.iconColor,
    required this.icon,
    required this.value,
    required this.label,
  });

  /// Background colour of the rounded icon tile.
  final Color iconColor;

  /// Icon rendered inside the tile.
  final IconData icon;

  /// Primary value (e.g. a count) shown large.
  final String value;

  /// Supporting label shown beneath the value.
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return NeumorphicCard(
      radius: BorderRadius.circular(AppRadiiTokens.md),
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
            ),
            child: Center(
              child: Icon(icon, size: 24, color: c.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppSemanticTextStyles.headingLg
                    .copyWith(color: c.textPrimary),
              ),
              Text(label, style: AppSemanticTextStyles.bodyMuted),
            ],
          ),
        ],
      ),
    );
  }
}
