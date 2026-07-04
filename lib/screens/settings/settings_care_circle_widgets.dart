import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/status_badge.dart';

import 'package:pet_circle/screens/settings/settings_widgets.dart'
    show settingsInviteAsset, settingsTrashAsset;

/// Full-width "Invite another" call-to-action — matches the Figma DS
/// secondary (purple-tile) pill button with a trailing user-add icon
/// (node 474:1867 in the settings-open frame).
class InviteButton extends StatelessWidget {
  const InviteButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PrimaryButton(
      label: l10n.inviteAnother,
      variant: PrimaryButtonVariant.secondary,
      onPressed: onTap,
      trailingIcon: SvgPicture.asset(settingsInviteAsset, width: 24, height: 24),
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
    this.status = StatusBadgeStatus.active,
    this.onRemove,
  });

  final String email;
  final String roleLabel;
  final Color roleColor;
  final String statusLabel;

  /// Status family for the member's status pill. Defaults to [active] since
  /// listed care-circle members are active; pass [StatusBadgeStatus.invited]
  /// for pending members.
  final StatusBadgeStatus status;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: AppRadiiTokens.borderRadiusCard,
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
                  style: AppSemanticTextStyles.labelSSemibold.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _RolePill(label: roleLabel, backgroundColor: roleColor),
                    const SizedBox(width: 4),
                    StatusBadge(
                      label: statusLabel,
                      status: status,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: AppRadiiTokens.borderRadiusField,
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

/// Small role pill (Admin/Member/Viewer). Matches the Figma "member-2"
/// (Admin, white bg) and "member-1" (Member, blush bg) treatments — the
/// text color always follows the caller-supplied [backgroundColor], mirroring
/// the DS role-pill/text-color pairing (blush bg -> blush text, white bg ->
/// tertiary text).
class _RolePill extends StatelessWidget {
  const _RolePill({
    required this.label,
    required this.backgroundColor,
  });

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final isNeutral = backgroundColor == c.surface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadiiTokens.borderRadiusPill,
      ),
      child: Text(
        label,
        style: AppSemanticTextStyles.captionBold.copyWith(
          color: isNeutral ? c.textTertiary : c.accentBlush,
        ),
      ),
    );
  }
}

/// Tappable "Alert thresholds" row inside the Measurement card — a blush
/// icon tile + title/description, matching Figma node 474:1177. The whole
/// row opens the threshold dialog; there is no separate "Configure" button.
class ConfigureRow extends StatelessWidget {
  const ConfigureRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: AppRadiiTokens.borderRadiusCard,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.accentBlushTile,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: c.accentBlush, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.alertThresholds,
                    style: AppSemanticTextStyles.labelLSemibold.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.customizeBpmRanges,
                    style: AppSemanticTextStyles.pcLabelMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
