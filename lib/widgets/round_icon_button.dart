import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// Visual variant for [RoundIconButton], mirroring the React `IconButton`
/// component in the Pet Circle v3 / Claude-Design system.
///
/// - [primary] — filled, dark ink background with light icon.
/// - [ghost]   — light surface background with tertiary icon and a
///   1px hairline border.
enum RoundIconButtonVariant { primary, ghost }

/// Circular icon button used across the app.
///
/// Public API is preserved from the previous implementation — callers can
/// continue passing `icon`, `backgroundColor`, `onTap`, `size`, and
/// `iconSize`. The new [variant] parameter selects the v3 visual treatment
/// and defaults to [RoundIconButtonVariant.primary].
///
/// When [backgroundColor] is provided it overrides the variant's background,
/// preserving backwards compatibility with existing callers.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.onTap,
    this.size = 54,
    this.iconSize = 20,
    this.variant = RoundIconButtonVariant.primary,
    this.semanticLabel,
  });

  /// Icon widget rendered at the centre of the button.
  final Widget icon;

  /// Optional background colour override. When null, the [variant] decides.
  final Color? backgroundColor;

  /// Tap handler. When null, the button renders as disabled (no ripple, no
  /// callback).
  final VoidCallback? onTap;

  /// Outer button diameter. Defaults to 54 to match the v3 design spec.
  final double size;

  /// Icon box size (the icon itself decides how it fills this box).
  final double iconSize;

  /// Visual variant — primary (filled dark) or ghost (light with hairline).
  final RoundIconButtonVariant variant;

  /// Accessibility label for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);

    final isGhost = variant == RoundIconButtonVariant.ghost;
    final resolvedBg = backgroundColor ??
        (isGhost ? colors.surface : colors.onSurface);
    final resolvedFg =
        isGhost ? colors.textTertiary : colors.surface;
    final borderSide = isGhost
        ? BorderSide(color: colors.hairline, width: 1)
        : BorderSide.none;

    final button = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: ShapeDecoration(
          color: resolvedBg,
          shape: CircleBorder(side: borderSide),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          borderRadius: AppRadiiTokens.borderRadiusFull,
          child: SizedBox(
            height: size,
            width: size,
            child: Center(
              child: IconTheme.merge(
                data: IconThemeData(color: resolvedFg, size: iconSize),
                child: SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (semanticLabel == null) return button;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: button,
    );
  }
}
