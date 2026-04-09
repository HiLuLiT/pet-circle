import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.isOpen = false,
    this.chevronController,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isOpen;
  final AnimationController? chevronController;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppSemanticTextStyles.labelSm,
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm + 4),
            decoration: BoxDecoration(
              color: AppPrimitives.skyLighter,
              borderRadius: AppRadiiTokens.borderRadiusLg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? '',
                    style: AppSemanticTextStyles.body.copyWith(
                      color: value == null
                          ? AppPrimitives.skyDark
                          : c.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (chevronController != null)
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(
                      CurvedAnimation(
                        parent: chevronController!,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: c.textSecondary,
                      size: 18,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: c.textSecondary,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
