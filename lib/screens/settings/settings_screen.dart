import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show appLocale, appDarkMode;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/bottom_nav_bar.dart';
import 'package:pet_circle/widgets/toggle_pill.dart';

const _settingsShareAsset = 'assets/figma/settings_share.svg';
const _settingsDownAsset = 'assets/figma/settings_down.svg';
const _settingsMoonAsset = 'assets/figma/settings_moon.svg';
const _settingsGlobeAsset = 'assets/figma/settings_globe.svg';
const _settingsChevronAsset = 'assets/figma/settings_chevron.svg';
const _settingsInviteAsset = 'assets/figma/settings_invite.svg';
const _settingsTrashAsset = 'assets/figma/settings_trash.svg';
const _settingsConfigureAsset = 'assets/figma/settings_configure.svg';

/// Push notification categories
/// - Medicine reminders: upcoming doses, missed doses
/// - Measurement reminders: scheduled SRR measurements
const kPushNotificationCategories = ['medicine_reminder', 'measurement_reminder'];

/// Emergency alert categories
/// - BPM exceeds alert threshold
/// - Missed medication for 24h+
const kEmergencyAlertCategories = ['bpm_threshold_exceeded', 'missed_medication_24h'];

/// Opens the settings as a slide-up drawer (modal bottom sheet).
class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key, required this.role});

  final AppUserRole role;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: _SettingsContent(
            role: role,
            scrollController: scrollController,
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }
}

/// Standalone settings screen (used when navigated to via route).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.role});

  final AppUserRole role;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Scaffold(
      backgroundColor: c.white,
      body: SafeArea(
        child: _SettingsContent(role: role),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onTap: (index) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.mainShell,
            arguments: {
              'role': role,
              'initialIndex': index,
            },
          );
        },
      ),
    );
  }
}

class _SettingsContent extends StatefulWidget {
  const _SettingsContent({
    required this.role,
    this.scrollController,
    this.onClose,
  });

  final AppUserRole role;
  final ScrollController? scrollController;
  final VoidCallback? onClose;

  @override
  State<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent> {
  bool _pushNotifications = false;
  bool _emergencyAlerts = false;
  bool _visionRR = false;
  bool _autoExport = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    return Container(
      color: c.white,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with title and optional close chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settings,
                        style: AppTextStyles.heading2.copyWith(
                          color: c.chocolate,
                          letterSpacing: -0.96,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.managePreferences,
                        style: AppTextStyles.body.copyWith(
                          color: c.chocolate,
                          fontSize: 14,
                          letterSpacing: -0.15,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onClose != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onClose,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.offWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.white, width: 2),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: c.chocolate,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
              _SettingsCard(
                title: l10n.appearance,
                subtitle: l10n.customizeLookAndFeel,
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      iconAsset: _settingsMoonAsset,
                      label: l10n.darkMode,
                      isOn: appDarkMode.value,
                      onChanged: () {
                        appDarkMode.value = !appDarkMode.value;
                        setState(() {}); // rebuild to reflect toggle state
                      },
                    ),
                    const SizedBox(height: 12),
                    _LanguageRow(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: l10n.careCircle,
                subtitle: l10n.manageCaregivers,
                trailing: _InviteButton(onTap: () {}),
                child: Column(
                  children: [
                    _CareCircleItem(
                      email: 'sarah@example.com',
                      roleLabel: l10n.owner,
                      roleColor: c.chocolate,
                      statusLabel: l10n.active,
                      statusColor: c.pink,
                    ),
                    const SizedBox(height: 12),
                    _CareCircleItem(
                      email: 'drsmith@vetclinic.com',
                      roleLabel: l10n.veterinarian,
                      roleColor: c.blue,
                      statusLabel: l10n.active,
                      statusColor: c.pink,
                    ),
                    const SizedBox(height: 12),
                    _CareCircleItem(
                      email: 'petsitter@example.com',
                      roleLabel: l10n.viewer,
                      roleColor: c.lightYellow,
                      statusLabel: l10n.pending,
                      statusColor: c.offWhite,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: l10n.notifications,
                subtitle: l10n.manageAlerts,
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      label: l10n.pushNotifications,
                      description: l10n.pushNotificationsDesc,
                      isOn: _pushNotifications,
                      onChanged: () => setState(() => _pushNotifications = !_pushNotifications),
                    ),
                    const SizedBox(height: 12),
                    _SettingsToggleRow(
                      label: l10n.emergencyAlerts,
                      description: l10n.emergencyAlertsDesc,
                      isOn: _emergencyAlerts,
                      onChanged: () => setState(() => _emergencyAlerts = !_emergencyAlerts),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: l10n.measurementSettings,
                subtitle: l10n.configureModes,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        _SettingsToggleRow(
                          label: l10n.visionRRCameraMode,
                          description: l10n.visionRRDesc,
                          isOn: _visionRR,
                          onChanged: () => setState(() => _visionRR = !_visionRR),
                        ),
                        Positioned(
                          top: 8,
                          right: 80,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.cherry,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.comingSoon,
                              style: AppTextStyles.caption.copyWith(
                                color: c.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ConfigureRow(onTap: () => _showThresholdDialog(context)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: l10n.dataAndPrivacy,
                subtitle: l10n.exportAndManage,
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      label: l10n.autoExportData,
                      description: l10n.autoExportDesc,
                      isOn: _autoExport,
                      onChanged: () => setState(() => _autoExport = !_autoExport),
                    ),
                    const SizedBox(height: 12),
                    _ActionRow(
                      iconAsset: _settingsDownAsset,
                      title: l10n.exportAllData,
                      description: l10n.exportAllDataDesc,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ActionRow(
                      iconAsset: _settingsShareAsset,
                      title: l10n.shareWithVet,
                      description: l10n.shareWithVetDesc,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: l10n.about,
                subtitle: l10n.appInfoAndSupport,
                child: Column(
                  children: [
                    _SimpleRow(
                      label: l10n.termsOfService,
                      onTap: () => _showInfoDialog(
                          context, l10n.termsOfService, l10n.termsOfServiceContent),
                    ),
                    const SizedBox(height: 12),
                    _SimpleRow(
                      label: l10n.privacyPolicy,
                      onTap: () => _showInfoDialog(
                          context, l10n.privacyPolicy, l10n.privacyPolicyContent),
                    ),
                    const SizedBox(height: 12),
                    _SimpleRow(
                      label: l10n.helpAndSupport,
                      onTap: () => _showInfoDialog(
                          context, l10n.helpAndSupport, l10n.helpAndSupportContent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
  }

  void _showThresholdDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalController = TextEditingController(text: '30');
    final alertController = TextEditingController(text: '40');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final c = AppColorsTheme.of(context);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.configureAlertThresholds, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
                const SizedBox(height: 8),
                Text(l10n.configureAlertThresholdsDesc, style: AppTextStyles.body.copyWith(color: c.chocolate)),
                const SizedBox(height: 24),
                Text(l10n.normalThresholdBpm, style: AppTextStyles.body.copyWith(color: c.chocolate, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: normalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 30',
                    filled: true,
                    fillColor: c.offWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.alertThresholdBpm, style: AppTextStyles.body.copyWith(color: c.chocolate, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: alertController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 40',
                    filled: true,
                    fillColor: c.offWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel, style: AppTextStyles.body.copyWith(color: c.chocolate)),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.thresholdsUpdated)),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: c.lightBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(l10n.save, style: AppTextStyles.body.copyWith(color: c.chocolate)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        final c = AppColorsTheme.of(context);
        return AlertDialog(
          backgroundColor: c.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
          content: SingleChildScrollView(
            child: Text(content, style: AppTextStyles.body.copyWith(color: c.chocolate)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close, style: AppTextStyles.body.copyWith(color: c.chocolate)),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
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
    final c = AppColorsTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.offWhite,
        borderRadius: BorderRadius.circular(16),
      ),
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
                      style: AppTextStyles.heading3.copyWith(
                        color: c.chocolate,
                        letterSpacing: -0.54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: c.chocolate,
                        fontSize: 14,
                        letterSpacing: -0.15,
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

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.label,
    required this.isOn,
    this.description,
    this.iconAsset,
    this.radius = 12,
    this.onChanged,
  });

  final String label;
  final String? description;
  final bool isOn;
  final String? iconAsset;
  final double radius;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (iconAsset != null) ...[
                  SvgPicture.asset(iconAsset!, width: 16, height: 16),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.body.copyWith(
                          color: c.chocolate,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.31,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: AppTextStyles.caption.copyWith(
                            color: c.chocolate,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChanged,
            child: TogglePill(isOn: isOn),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final currentLocale = Localizations.localeOf(context);
    final isHebrew = currentLocale.languageCode == 'he';
    final currentLanguageName = isHebrew ? l10n.hebrew : l10n.english;

    return GestureDetector(
      onTap: () => _showLanguagePicker(context, l10n),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(_settingsGlobeAsset, width: 16, height: 16),
                const SizedBox(width: 8),
                Text(
                  l10n.language,
                  style: AppTextStyles.body.copyWith(
                    color: c.chocolate,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.31,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.pink,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    currentLanguageName,
                    style: AppTextStyles.body.copyWith(
                      color: c.chocolate,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(_settingsChevronAsset, width: 16, height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final c = AppColorsTheme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.english),
                trailing: Localizations.localeOf(context).languageCode == 'en'
                    ? Icon(Icons.check, color: c.chocolate)
                    : null,
                onTap: () {
                  appLocale.value = const Locale('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l10n.hebrew),
                trailing: Localizations.localeOf(context).languageCode == 'he'
                    ? Icon(Icons.check, color: c.chocolate)
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

class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onTap});

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
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SvgPicture.asset(_settingsInviteAsset, width: 16, height: 16),
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

class _CareCircleItem extends StatelessWidget {
  const _CareCircleItem({
    required this.email,
    required this.roleLabel,
    required this.roleColor,
    required this.statusLabel,
    required this.statusColor,
  });

  final String email;
  final String roleLabel;
  final Color roleColor;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: SvgPicture.asset(
                _settingsTrashAsset,
                width: 16,
                height: 16,
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
        borderRadius: BorderRadius.circular(14),
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

class _ConfigureRow extends StatelessWidget {
  const _ConfigureRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(_settingsConfigureAsset,
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.white,
          borderRadius: BorderRadius.circular(12),
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
                      style: AppTextStyles.body.copyWith(
                        color: c.chocolate,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.31,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: c.chocolate,
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

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: c.chocolate,
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

