import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// Outlined social-auth button (Google / Apple) used on the auth screens.
///
/// Renders a full-width, surface-filled, hairline-bordered button with a
/// leading [icon] widget and a centered [label]. Disabled when [onTap] is
/// null. Visuals mirror the original per-screen `_SocialButton` definitions
/// from the login / create-account screens (preserved 1:1):
/// - height 48, full width
/// - [AppSemanticColors.surface] background, [AppSemanticColors.divider] border
/// - [AppRadiiTokens.md] corner radius, no elevation
/// - icon + 12px gap + label ([AppSemanticTextStyles.body], 500 weight)
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  /// Leading visual — typically an `Image.asset` logo or an `Icon`.
  final Widget icon;

  /// Localised button label (e.g. "Continue with Google").
  final String label;

  /// Tap handler; pass `null` to render the disabled state.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: c.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiiTokens.md),
          ),
          backgroundColor: c.surface,
          elevation: 0,
        ).copyWith(
          shadowColor: WidgetStatePropertyAll(
            Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppSpacingTokens.sm + 4),
            Text(
              label,
              style: AppSemanticTextStyles.body.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
