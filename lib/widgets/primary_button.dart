import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

enum PrimaryButtonVariant { filled, outlined }

/// Pill-shaped button matching the Figma "Controls / Buttons" component.
///
/// Figma spec: `px-32 py-16, rounded-48, 16px medium text`.
/// - [variant] `filled`: Primary/Base bg, white text.
/// - [variant] `outlined`: transparent bg, Primary/Base 1px border, primary text.
///
/// Use [icon] for a leading icon, [trailingIcon] for a trailing icon.
/// Use [child] to fully override the button content (label is ignored).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius = AppRadiiTokens.xl,
    this.icon,
    this.trailingIcon,
    this.child,
    this.variant = PrimaryButtonVariant.filled,
    this.fullWidth = true,
  }) : assert(label != null || child != null,
            'Either label or child must be provided');

  final String? label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final double borderRadius;
  final IconData? icon;
  final Widget? trailingIcon;
  final Widget? child;
  final PrimaryButtonVariant variant;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final isFilled = variant == PrimaryButtonVariant.filled;
    final bg = backgroundColor ?? (isFilled ? c.primary : Colors.transparent);
    final fg = foregroundColor ?? (isFilled ? c.onPrimary : c.primary);
    final style = textStyle ?? AppSemanticTextStyles.button.copyWith(color: fg);

    final buttonChild = child ??
        Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 22),
              const SizedBox(width: AppSpacingTokens.sm),
            ],
            Text(label!, style: style),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppSpacingTokens.sm),
              trailingIcon!,
            ],
          ],
        );

    final button = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: bg,
        disabledBackgroundColor: bg.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.xl,
          vertical: AppSpacingTokens.md,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        side: isFilled
            ? BorderSide.none
            : BorderSide(color: foregroundColor ?? c.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed,
      child: buttonChild,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
