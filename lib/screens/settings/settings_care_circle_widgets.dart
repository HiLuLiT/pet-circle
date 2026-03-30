import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_theme.dart';

import 'package:pet_circle/screens/settings/settings_widgets.dart'
    show settingsInviteAsset, settingsTrashAsset, settingsConfigureAsset;

class InviteButton extends StatelessWidget {
  const InviteButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.lightBlue,
          borderRadius: const BorderRadius.all(AppRadii.xs),
        ),
        child: Row(
          children: [
            SvgPicture.asset(settingsInviteAsset, width: 16, height: 16),
            const SizedBox(width: 6),
            Text(
              l10n.invite,
              style: AppTextStyles.body.copyWith(
                color: c.chocolate,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CareCircleItem extends StatelessWidget {
  const CareCircleItem({
    super.key,
    required this.email,
    required this.roleLabel,
    required this.roleColor,
    required this.statusLabel,
    required this.statusColor,
    this.onRemove,
  });

  final String email;
  final String roleLabel;
  final Color roleColor;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: const BorderRadius.all(AppRadii.small),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: AppTextStyles.body.copyWith(
                    color: c.chocolate,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.31,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Badge(
                      label: roleLabel,
                      backgroundColor: roleColor,
                      textColor: roleColor == c.lightYellow
                          ? c.chocolate
                          : c.white,
                    ),
                    const SizedBox(width: 4),
                    _Badge(
                      label: statusLabel,
                      backgroundColor: statusColor,
                      textColor: c.chocolate,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.white,
                borderRadius: const BorderRadius.all(AppRadii.small),
              ),
              child: Center(
                child: SvgPicture.asset(
                  settingsTrashAsset,
                  width: 16,
                  height: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(AppRadii.small),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ConfigureRow extends StatelessWidget {
  const ConfigureRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: const BorderRadius.all(AppRadii.small),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.alertThresholds,
                  style: AppTextStyles.body.copyWith(
                    color: c.chocolate,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.31,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.customizeBpmRanges,
                  style: AppTextStyles.caption.copyWith(
                    color: c.chocolate,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.lightBlue,
                borderRadius: const BorderRadius.all(AppRadii.xs),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(settingsConfigureAsset,
                      width: 16, height: 16),
                  const SizedBox(width: 6),
                  Text(
                    l10n.configure,
                    style: AppTextStyles.body.copyWith(
                      color: c.chocolate,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
