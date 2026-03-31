import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

enum PrimaryButtonVariant { filled, outlined }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textStyle,
    this.minHeight = 58,
    this.borderRadius = 48,
    this.icon,
    this.variant = PrimaryButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double minHeight;
  final double borderRadius;
  final IconData? icon;
  final PrimaryButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final isFilled = variant == PrimaryButtonVariant.filled;
    final bg = backgroundColor ?? (isFilled ? c.primary : c.surface);
    final fg = isFilled ? c.onPrimary : c.primary;
    final style = textStyle ?? AppSemanticTextStyles.button.copyWith(color: fg);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            elevation: 0,
            side: isFilled
                ? BorderSide.none
                : BorderSide(color: c.primary.withValues(alpha: 0.15)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: style.color ?? fg, size: 22),
                const SizedBox(width: AppSpacingTokens.sm + 2),
              ],
              Text(label, style: style),
            ],
          ),
        ),
      ),
    );
  }
}
