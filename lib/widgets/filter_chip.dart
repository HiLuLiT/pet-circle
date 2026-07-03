import 'package:flutter/material.dart';

import '../theme/semantic/color_scheme.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/typography.dart';

/// Pill-shaped filter chip used in PC v3 (Claude-Design) palette.
///
/// Selected state uses the periwinkle chip background; unselected uses the
/// recessed surface tone. Named `AppFilterChip` to avoid collision with
/// Flutter Material's [FilterChip].
///
/// Mirrors the React `FilterChip` component:
/// - padding: 9px vertical / 16px horizontal
/// - radius: fully pill
/// - text: Instrument Sans 14px / weight 600
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);
    final Color background =
        selected ? colors.accentPeriwinkleChip : colors.surfaceRecessed;
    // Both states use on-palette ink; selected reads slightly stronger via
    // the chip background contrast.
    final Color textColor =
        selected ? colors.onSurface : colors.textPrimary;

    final BorderRadius radius =
        BorderRadius.circular(AppRadiiTokens.pcPill);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
          ),
          child: Text(
            label,
            style: AppTypography.pcLabelSemibold.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
