import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// Social-auth button (Google / Apple) used on the auth screens — matches
/// the Figma DS "Social Auth Button" component (node 535:1313, DS node
/// 402-1191).
///
/// Renders a full-width, borderless white button with a leading [icon]
/// widget and a centered [label]. Disabled when [onTap] is null.
/// - height 52, full width
/// - [AppSemanticColors.surface] background, no border
/// - [AppRadiiTokens.pcField] (12) corner radius, no elevation
/// - icon + 12px gap + label (Label/L SemiBold, 15/20)
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
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiiTokens.pcField),
          ),
          backgroundColor: c.surface,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppSpacingTokens.sm + 4),
            Text(
              label,
              style: AppSemanticTextStyles.labelLSemibold.copyWith(
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
