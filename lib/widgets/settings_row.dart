import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/theme/app_theme.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.description,
    this.iconAsset,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? description;
  final String? iconAsset;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: c.white,
          borderRadius: const BorderRadius.all(AppRadii.small),
        ),
        child: Row(
          children: [
            if (iconAsset != null) ...[
              SvgPicture.asset(iconAsset!, width: 16, height: 16),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: c.chocolate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description!,
                      style: AppTextStyles.caption.copyWith(color: c.chocolate),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
