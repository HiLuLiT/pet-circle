import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/config/app_config.dart' show appDarkMode;
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

import 'package:pet_circle/screens/settings/settings_widgets.dart';
import 'package:pet_circle/screens/settings/settings_care_circle_widgets.dart';
import 'package:pet_circle/screens/settings/settings_dialogs.dart';

/// Push notification categories
/// - Medicine reminders: upcoming doses, missed doses
/// - Measurement reminders: scheduled SRR measurements
const kPushNotificationCategories = ['medicine_reminder', 'measurement_reminder'];

/// Emergency alert categories
/// - BPM exceeds alert threshold
/// - Missed medication for 24h+
const kEmergencyAlertCategories = ['bpm_threshold_exceeded', 'missed_medication_24h'];

class SettingsContent extends StatefulWidget {
  const SettingsContent({
    super.key,
    this.scrollController,
    this.onClose,
  });

  final ScrollController? scrollController;
  final VoidCallback? onClose;

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent>
    with SettingsDialogsMixin {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    return Container(
      color: c.background,
      child: ListenableBuilder(
        listenable: petStore,
        builder: (context, _) {
          final activePet = petStore.activePet;
          final access = petStore.accessForPet(activePet);
          final canManageActivePet =
              activePet != null && access.canManageCircle;

          return SingleChildScrollView(
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
                        style: AppSemanticTextStyles.title3.copyWith(
                          color: c.textPrimary,
                          letterSpacing: -0.96,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.managePreferences,
                        style: AppSemanticTextStyles.body.copyWith(
                          color: c.textPrimary,
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
                        color: c.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.background, width: 2),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: c.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
              ActionRow(
                iconAsset: settingsConfigureAsset,
                title: l10n.editProfile,
                description: userStore.currentUser?.name ?? '',
                onTap: () => showEditProfileDialog(context),
              ),
              const SizedBox(height: 16),
              SettingsCard(
                title: l10n.appearance,
                subtitle: l10n.customizeLookAndFeel,
                child: Column(
                  children: [
                    SettingsToggleRow(
                      iconAsset: settingsMoonAsset,
                      label: l10n.darkMode,
                      isOn: appDarkMode.value,
                      onChanged: () {
                        appDarkMode.value = !appDarkMode.value;
                        setState(() {}); // rebuild to reflect toggle state
                      },
                    ),
                    const SizedBox(height: 12),
                    const LanguageRow(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                return SettingsCard(
                  title: l10n.careCircle,
                  subtitle: l10n.manageCaregivers,
                  trailing: canManageActivePet
                      ? InviteButton(onTap: () => showInviteDialog(context))
                      : null,
                  child: Builder(builder: (context) {
                    if (activePet == null) {
                      return Text(l10n.noPetsYet, style: AppSemanticTextStyles.body);
                    }
                    final members = activePet.careCircle;
                    if (members.isEmpty) {
                      return Text(l10n.noCareCircleMembers, style: AppSemanticTextStyles.body);
                    }
                    return Column(
                      children: members.map((member) {
                        final isOwner = member.role == CareCircleRole.owner;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CareCircleItem(
                            email: member.name,
                            roleLabel: member.roleLabel,
                            roleColor: isOwner ? c.textPrimary : c.primaryLight,
                            statusLabel: l10n.active,
                            statusColor: c.primaryLight,
                            onRemove: canManageActivePet
                                ? () => confirmRemoveMember(context, activePet.name, member.name)
                                : null,
                          ),
                        );
                      }).toList(),
                    );
                  }),
                );
              }),
              const SizedBox(height: 16),
              SettingsCard(
                title: l10n.notifications,
                subtitle: l10n.manageAlerts,
                child: Column(
                  children: [
                    SettingsToggleRow(
                      label: l10n.pushNotifications,
                      description: l10n.pushNotificationsDesc,
                      isOn: settingsStore.pushNotifications,
                      onChanged: () async {
                        await settingsStore.togglePushNotifications();
                        if (!mounted) return;
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    SettingsToggleRow(
                      label: l10n.emergencyAlerts,
                      description: l10n.emergencyAlertsDesc,
                      isOn: settingsStore.emergencyAlerts,
                      onChanged: () async {
                        await settingsStore.toggleEmergencyAlerts();
                        if (!mounted) return;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SettingsCard(
                title: l10n.measurementSettings,
                subtitle: l10n.configureModes,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SettingsToggleRow(
                          label: l10n.visionRRCameraMode,
                          description: l10n.visionRRDesc,
                          isOn: settingsStore.visionRREnabled,
                          onChanged: () async {
                            await settingsStore.toggleVisionRR();
                            if (!mounted) return;
                            setState(() {});
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 80,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.error,
                              borderRadius: AppRadiiTokens.borderRadiusMd,
                            ),
                            child: Text(
                              l10n.comingSoon,
                              style: AppSemanticTextStyles.caption.copyWith(
                                color: c.background,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConfigureRow(onTap: () => showThresholdDialog(context)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SettingsCard(
                title: l10n.dataAndPrivacy,
                subtitle: l10n.exportAndManage,
                child: Column(
                  children: [
                    SettingsToggleRow(
                      label: l10n.autoExportData,
                      description: l10n.autoExportDesc,
                      isOn: settingsStore.autoExport,
                      onChanged: () async {
                        await settingsStore.toggleAutoExport();
                        if (!mounted) return;
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionRow(
                      iconAsset: settingsDownAsset,
                      title: l10n.exportAllData,
                      description: l10n.exportAllDataDesc,
                      onTap: () => showExportDataDialog(context),
                    ),
                    const SizedBox(height: 12),
                    ActionRow(
                      iconAsset: settingsShareAsset,
                      title: l10n.shareWithVet,
                      description: l10n.shareWithVetDesc,
                      onTap: canManageActivePet
                          ? () => showShareWithVetDialog(context)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SettingsCard(
                title: l10n.about,
                subtitle: l10n.appInfoAndSupport,
                child: Column(
                  children: [
                    SimpleRow(
                      label: l10n.termsOfService,
                      onTap: () => showInfoDialog(
                          context, l10n.termsOfService, l10n.termsOfServiceContent),
                    ),
                    const SizedBox(height: 12),
                    SimpleRow(
                      label: l10n.privacyPolicy,
                      onTap: () => showInfoDialog(
                          context, l10n.privacyPolicy, l10n.privacyPolicyContent),
                    ),
                    const SizedBox(height: 12),
                    SimpleRow(
                      label: l10n.helpAndSupport,
                      onTap: () => showInfoDialog(
                          context, l10n.helpAndSupport, l10n.helpAndSupportContent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => showSignOutDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.error.withValues(alpha: 0.08),
                    borderRadius: AppRadiiTokens.borderRadiusLg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 18, color: c.error),
                      const SizedBox(width: 8),
                      Text(
                        l10n.signOut,
                        style: AppSemanticTextStyles.body.copyWith(
                          color: c.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          );
        },
      ),
    );
  }
}
