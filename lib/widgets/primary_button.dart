import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/theme/tokens/typography.dart';

/// Variants for the Pet Circle v3 / Claude-Design button.
///
/// - [filled] (alias: primary): ink (#161616) bg, white fg, weight 700.
/// - [secondary]: purpleTile (#C3AEF0) bg, ink fg, weight 700.
/// - [outlined] (alias: tertiary): white surface bg, ink fg, hairline 1px
///   inset border, weight 600.
enum PrimaryButtonVariant { filled, secondary, outlined }

/// Pill-shaped button matching the React/Figma "Button" component in the
/// PC v3 (Claude-Design) palette.
///
/// Spec: height 56, horizontal padding 26, fully-rounded pill, fontSize 16.
/// - filled/primary  : bg = onSurface (ink), fg = surface (white), 700
/// - secondary       : bg = accentPurpleTile, fg = onSurface (ink), 700
/// - outlined/tertiary: bg = surface (white), fg = onSurface (ink),
///                      1px hairline border, 600 weight, no shadow
/// - disabled        : bg = #E2DED5, fg = #A7A2AE
///
/// Optional [icon] (leading) and [trailingIcon] flank the [label], with an
/// 8px gap. [child] fully overrides the inner content. The public API
/// preserves the previous fields ([backgroundColor], [foregroundColor],
/// [textStyle], [borderRadius], [fullWidth]) for backwards compatibility
/// with existing call sites.
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

  // Disabled-state colors are spec'd inline; they don't live in the token
  // system because they're shared across all variants in the React source.
  static const Color _disabledBg = Color(0xFFE2DED5);
  static const Color _disabledFg = Color(0xFFA7A2AE);

  // Spec: 16px / 600 weight for tertiary (outlined). Defined here because
  // there's no semantic style with exactly this combo (pcBodyBold is 700,
  // pcBodyMedium is 500).
  static TextStyle _outlinedLabelStyle(Color fg) =>
      AppTypography.pcBodySemibold.copyWith(color: fg, height: 1.0);

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final isEnabled = onPressed != null;
    final isOutlined = variant == PrimaryButtonVariant.outlined;
    final isSecondary = variant == PrimaryButtonVariant.secondary;

    // ── Resolve colors ──────────────────────────────────────────────────────
    final Color defaultBg;
    final Color defaultFg;
    if (isOutlined) {
      defaultBg = c.surface;
      defaultFg = c.onSurface;
    } else if (isSecondary) {
      defaultBg = c.accentPurpleTile;
      defaultFg = c.onSurface;
    } else {
      // filled / primary
      defaultBg = c.onSurface;
      defaultFg = c.surface;
    }

    final bg = backgroundColor ?? defaultBg;
    final fg = foregroundColor ?? defaultFg;
    final effectiveBg = isEnabled ? bg : _disabledBg;
    final effectiveFg = isEnabled ? fg : _disabledFg;

    // ── Label style ─────────────────────────────────────────────────────────
    final TextStyle baseStyle = isOutlined
        ? _outlinedLabelStyle(effectiveFg)
        : AppSemanticTextStyles.pcBodyBold.copyWith(
            color: effectiveFg,
            height: 1.0,
          );
    final style = textStyle?.copyWith(color: effectiveFg) ?? baseStyle;

    // ── Inner content ───────────────────────────────────────────────────────
    final Widget buttonChild = child ??
        Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: effectiveFg, size: 20),
              const SizedBox(width: AppSpacingTokens.sm), // 8px gap
            ],
            Flexible(
              child: Text(
                label!,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppSpacingTokens.sm), // 8px gap
              IconTheme.merge(
                data: IconThemeData(color: effectiveFg, size: 20),
                child: trailingIcon!,
              ),
            ],
          ],
        );

    // ── Style: pill, 56h, 0x26 padding, optional hairline border ────────────
    final BorderSide borderSide = isOutlined
        ? BorderSide(color: c.hairline, width: 1.0)
        : BorderSide.none;

    final ButtonStyle bStyle = TextButton.styleFrom(
      backgroundColor: effectiveBg,
      disabledBackgroundColor: _disabledBg,
      foregroundColor: effectiveFg,
      disabledForegroundColor: _disabledFg,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      minimumSize: const Size(0, 56),
      fixedSize: const Size.fromHeight(56),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: borderSide,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    final button = TextButton(
      style: bStyle,
      onPressed: onPressed,
      child: buttonChild,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
