import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadiiTokens.borderRadiusFull,
      ),
      child: Text(
        label,
        style: AppSemanticTextStyles.labelSm.copyWith(
          color: c.onPrimary,
        ),
      ),
    );
  }
}
