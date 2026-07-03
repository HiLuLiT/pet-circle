import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/config/app_config.dart' show appLocale;
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_card.dart';
import 'package:pet_circle/widgets/app_toggle.dart';

const settingsShareAsset = 'assets/figma/settings_share.svg';
const settingsDownAsset = 'assets/figma/settings_down.svg';
const settingsMoonAsset = 'assets/figma/settings_moon.svg';
const settingsGlobeAsset = 'assets/figma/settings_globe.svg';
const settingsChevronAsset = 'assets/figma/settings_chevron.svg';
const settingsInviteAsset = 'assets/figma/settings_invite.svg';
const settingsTrashAsset = 'assets/figma/settings_trash.svg';
const settingsConfigureAsset = 'assets/figma/settings_configure.svg';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppSemanticTextStyles.headingH2.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppSemanticTextStyles.labelSRegular.copyWith(
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.label,
    required this.isOn,
    this.description,
    this.iconAsset,
    this.iconTileColor,
    this.onChanged,
  });

  final String label;
  final String? description;
  final bool isOn;
  final String? iconAsset;

  /// Background color for the circular icon tile behind [iconAsset] (e.g.
  /// `c.accentPeriwinkleTile` for Dark mode, `c.accentBlushTile` for
  /// VisionRR). Ignored when [iconAsset] is null.
  final Color? iconTileColor;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: AppRadiiTokens.borderRadiusCard,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (iconAsset != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconTileColor ?? c.accentPeriwinkleTile,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(iconAsset!, width: 24, height: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppSemanticTextStyles.labelLSemibold.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      if (description != null) ...[
                        Text(
                          description!,
                          style: AppSemanticTextStyles.pcLabelMuted,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppToggle(
            value: isOn,
            onChanged: onChanged == null ? null : (_) => onChanged!(),
          ),
        ],
      ),
    );
  }
}

class LanguageRow extends StatelessWidget {
  const LanguageRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final currentLocale = Localizations.localeOf(context);
    final isHebrew = currentLocale.languageCode == 'he';
    final currentLanguageName = isHebrew ? l10n.hebrew : l10n.english;

    return GestureDetector(
      onTap: () => _showLanguagePicker(context, l10n),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: AppRadiiTokens.borderRadiusField,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.accentMintTile,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(settingsGlobeAsset, width: 24, height: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.language,
                          style: AppSemanticTextStyles.labelLSemibold.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                        Text(
                          currentLanguageName,
                          style: AppSemanticTextStyles.pcLabelMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: c.textTertiary, size: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final c = AppSemanticColors.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.english),
                trailing: Localizations.localeOf(context).languageCode == 'en'
                    ? Icon(Icons.check, color: c.textPrimary)
                    : null,
                onTap: () {
                  appLocale.value = const Locale('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l10n.hebrew),
                trailing: Localizations.localeOf(context).languageCode == 'he'
                    ? Icon(Icons.check, color: c.textPrimary)
                    : null,
                onTap: () {
                  appLocale.value = const Locale('he');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap == null ? c.background.withValues(alpha: 0.7) : c.background,
          borderRadius: AppRadiiTokens.borderRadiusSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(iconAsset, width: 16, height: 16),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppSemanticTextStyles.body.copyWith(
                        color: onTap == null
                            ? c.textPrimary.withValues(alpha: 0.5)
                            : c.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.31,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppSemanticTextStyles.caption.copyWith(
                        color: onTap == null
                            ? c.textPrimary.withValues(alpha: 0.5)
                            : c.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleRow extends StatelessWidget {
  const SimpleRow({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: AppRadiiTokens.borderRadiusSm,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppSemanticTextStyles.body.copyWith(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.31,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
