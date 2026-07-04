import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/theme/tokens/typography.dart';

/// Variants for the Pet Circle v3 / Claude-Design button — matches the
/// Figma DS "Button" component (node 442:8188, DS node 402-1191).
///
/// - [filled] (alias: primary): purple (#7E5CE0) bg, white fg, Bold 16/22.
/// - [secondary]: purpleTile (#C3AEF0) bg, ink fg, Bold 16/22.
/// - [outlined] (alias: tertiary): transparent bg, ink fg, 1px ink border,
///   Bold 16/22 (matches DS Tertiary — NOT a filled/hairline surface).
/// - [link] (Figma 442:8683): no bg, no border, intrinsic size. Ink text,
///   SemiBold 14/20. Optional leading/trailing icons (20px, 4px gap).
///   Never full-width or 56h.
/// - [miniPrimary] (Figma 474:2550): purple bg, white text, SemiBold 14/20,
///   padding 24x12 (≈44h, not 56h), pill radius, optional trailing icon
///   (20px, 8px gap). Not full-width by default.
enum PrimaryButtonVariant { filled, secondary, outlined, link, miniPrimary }

/// Pill-shaped button matching the Figma DS "Button" component (node
/// 442:8188) in the PC v3 (Claude-Design) palette.
///
/// Spec: ~54h (padding 32x16), fully-rounded pill, fontSize 16 Bold 16/22.
/// - filled/primary   : bg = primary (purple), fg = onPrimary (white)
/// - secondary        : bg = accentPurpleTile, fg = onSurface (ink)
/// - outlined/tertiary: transparent bg, fg = onSurface (ink),
///                      1px ink border, no shadow
/// - disabled         : bg = #E2DED5, fg = #A7A2AE
///
/// Optional [icon] (leading) and [trailingIcon] flank the [label]. [child]
/// fully overrides the inner content. The public API preserves the
/// previous fields ([backgroundColor], [foregroundColor], [textStyle],
/// [borderRadius], [fullWidth]) for backwards compatibility with existing
/// call sites.
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
    this.fullWidth,
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

  /// When null, the per-variant default applies: `true` for
  /// filled/secondary/outlined (unchanged legacy behavior), `false` for the
  /// intrinsic [PrimaryButtonVariant.link] and [PrimaryButtonVariant.miniPrimary].
  final bool? fullWidth;

  /// Resolves the effective full-width behavior. Legacy variants keep their
  /// historical `true` default; the new intrinsic variants default to `false`.
  bool _resolveFullWidth() {
    if (fullWidth != null) return fullWidth!;
    switch (variant) {
      case PrimaryButtonVariant.link:
      case PrimaryButtonVariant.miniPrimary:
        return false;
      case PrimaryButtonVariant.filled:
      case PrimaryButtonVariant.secondary:
      case PrimaryButtonVariant.outlined:
        return true;
    }
  }

  // Disabled-state colors are spec'd inline; they don't live in the token
  // system because they're shared across all variants in the React source.
  static const Color _disabledBg = Color(0xFFE2DED5);
  static const Color _disabledFg = Color(0xFFA7A2AE);

  // DS Tertiary label style matches Primary/Secondary: Bold 16/22
  // (AppSemanticTextStyles.pcButton), just with a different fg color.
  static TextStyle _outlinedLabelStyle(Color fg) =>
      AppSemanticTextStyles.pcButton.copyWith(color: fg);

  // SemiBold 14 / lineHeight 20 — the label style shared by the new
  // [link] and [miniPrimary] variants. Height collapsed to 1.0 to match the
  // tight Figma button layout (vertical centering handled by padding).
  static TextStyle _miniLabelStyle(Color fg) =>
      AppTypography.pcLabelSemibold.copyWith(color: fg, height: 1.0);

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);

    // ── New intrinsic variants branch off before the legacy 56h/pad-26 path ──
    if (variant == PrimaryButtonVariant.link) {
      return _buildLink(context, c);
    }
    if (variant == PrimaryButtonVariant.miniPrimary) {
      return _buildMiniPrimary(context, c);
    }

    final isEnabled = onPressed != null;
    final isOutlined = variant == PrimaryButtonVariant.outlined;
    final isSecondary = variant == PrimaryButtonVariant.secondary;

    // ── Resolve colors ──────────────────────────────────────────────────────
    final Color defaultBg;
    final Color defaultFg;
    if (isOutlined) {
      // DS Tertiary: transparent bg, ink border/text (not a filled surface).
      defaultBg = Colors.transparent;
      defaultFg = c.onSurface;
    } else if (isSecondary) {
      defaultBg = c.accentPurpleTile;
      defaultFg = c.onSurface;
    } else {
      // filled / primary — DS Primary is purple, not ink.
      defaultBg = c.primary;
      defaultFg = c.onPrimary;
    }

    final bg = backgroundColor ?? defaultBg;
    final fg = foregroundColor ?? defaultFg;
    final effectiveBg = isEnabled ? bg : _disabledBg;
    final effectiveFg = isEnabled ? fg : _disabledFg;
    final isFullWidth = _resolveFullWidth();

    // ── Label style — DS Button text is Bold 16/22 for every fill variant ───
    final TextStyle baseStyle = isOutlined
        ? _outlinedLabelStyle(effectiveFg)
        : AppSemanticTextStyles.pcButton.copyWith(color: effectiveFg);
    final style = textStyle?.copyWith(color: effectiveFg) ?? baseStyle;

    // Icon gap matches DS: 16px for Primary/Secondary, 12px for Tertiary.
    final double iconGap = isOutlined
        ? AppSpacingTokens.sm + 4 // 12px
        : AppSpacingTokens.md; // 16px

    // ── Inner content ───────────────────────────────────────────────────────
    final Widget buttonChild = child ??
        Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: effectiveFg, size: 24),
              SizedBox(width: iconGap),
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
              SizedBox(width: iconGap),
              IconTheme.merge(
                data: IconThemeData(color: effectiveFg, size: 24),
                child: trailingIcon!,
              ),
            ],
          ],
        );

    // ── Style: pill, ~54h (32x16 padding), optional 1px ink border ──────────
    final BorderSide borderSide = isOutlined
        ? BorderSide(color: c.onSurface, width: 1.0)
        : BorderSide.none;

    final ButtonStyle bStyle = TextButton.styleFrom(
      backgroundColor: effectiveBg,
      disabledBackgroundColor: _disabledBg,
      foregroundColor: effectiveFg,
      disabledForegroundColor: _disabledFg,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      minimumSize: const Size(0, 54),
      fixedSize: const Size.fromHeight(54),
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

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  // ── link variant (Figma 442:8683) ────────────────────────────────────────
  // Transparent, borderless, intrinsic-size text button. Ink text, SemiBold
  // 14/20, optional leading/trailing icons (20px) with a 4px gap. No fixed
  // 56h, no horizontal padding, never full-width.
  Widget _buildLink(BuildContext context, AppSemanticColors c) {
    final isEnabled = onPressed != null;
    final fg = foregroundColor ?? (isEnabled ? c.onSurface : _disabledFg);

    final TextStyle baseStyle = _miniLabelStyle(fg);
    final style = textStyle?.copyWith(color: fg) ?? baseStyle;

    final Widget buttonChild = child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: AppSpacingTokens.xs), // 4px gap
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
              const SizedBox(width: AppSpacingTokens.xs), // 4px gap
              IconTheme.merge(
                data: IconThemeData(color: fg, size: 20),
                child: trailingIcon!,
              ),
            ],
          ],
        );

    final ButtonStyle bStyle = TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      foregroundColor: fg,
      disabledForegroundColor: _disabledFg,
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
    );

    return TextButton(
      style: bStyle,
      onPressed: onPressed,
      child: buttonChild,
    );
  }

  // ── miniPrimary variant (Figma 474:2550) ─────────────────────────────────
  // Compact purple pill: primary bg, onPrimary (white) text, SemiBold 14/20,
  // padding 24x12 (≈44h, not the fixed 56h), pill radius, optional trailing
  // icon (20px, 8px gap). Not full-width by default.
  Widget _buildMiniPrimary(BuildContext context, AppSemanticColors c) {
    final isEnabled = onPressed != null;
    final bg = backgroundColor ?? c.primary;
    final fg = foregroundColor ?? c.onPrimary;
    final effectiveBg = isEnabled ? bg : _disabledBg;
    final effectiveFg = isEnabled ? fg : _disabledFg;
    final isFullWidth = _resolveFullWidth();

    final TextStyle baseStyle = _miniLabelStyle(effectiveFg);
    final style = textStyle?.copyWith(color: effectiveFg) ?? baseStyle;

    final Widget buttonChild = child ??
        Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
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

    final ButtonStyle bStyle = TextButton.styleFrom(
      backgroundColor: effectiveBg,
      disabledBackgroundColor: _disabledBg,
      foregroundColor: effectiveFg,
      disabledForegroundColor: _disabledFg,
      // 24 horizontal / 12 vertical → ≈44h with 20px content.
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcPill),
      ),
    );

    final button = TextButton(
      style: bStyle,
      onPressed: onPressed,
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
