import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

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
    final c = AppColorsTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: c.white,
              borderRadius: const BorderRadius.all(AppRadii.xs),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? '',
                    style: AppTextStyles.body.copyWith(
                      color: value == null
                          ? c.chocolate.withValues(alpha: 0.3)
                          : c.chocolate,
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
                      color: c.chocolate,
                      size: 18,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: c.chocolate,
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
