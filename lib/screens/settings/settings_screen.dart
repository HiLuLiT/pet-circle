import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show appLocale, appDarkMode, kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/invitation.dart';
import 'package:pet_circle/services/invitation_service.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/bottom_nav_bar.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';
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
          borderRadius: const BorderRadius.vertical(top: AppRadii.medium),
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
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    return Container(
      color: c.white,
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
              _ActionRow(
                iconAsset: _settingsConfigureAsset,
                title: l10n.editProfile,
                description: userStore.currentUser?.name ?? '',
                onTap: () => _showEditProfileDialog(context),
              ),
              const SizedBox(height: 16),
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
              Builder(builder: (context) {
                return _SettingsCard(
                  title: l10n.careCircle,
                  subtitle: l10n.manageCaregivers,
                  trailing: canManageActivePet
                      ? _InviteButton(onTap: () => _showInviteDialog(context))
                      : null,
                  child: Builder(builder: (context) {
                    if (activePet == null) {
                      return Text(l10n.noPetsYet, style: AppTextStyles.body);
                    }
                    final members = activePet.careCircle;
                    if (members.isEmpty) {
                      return Text(l10n.noCareCircleMembers, style: AppTextStyles.body);
                    }
                    return Column(
                      children: members.map((member) {
                        final isAdmin = member.role == CareCircleRole.admin;
                        final isViewer = member.role == CareCircleRole.viewer;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CareCircleItem(
                            email: member.name,
                            roleLabel: member.roleLabel,
                            roleColor: isViewer ? c.blue : isAdmin ? c.chocolate : c.lightYellow,
                            statusLabel: l10n.active,
                            statusColor: c.pink,
                            onRemove: canManageActivePet
                                ? () => _confirmRemoveMember(context, activePet.name, member.name)
                                : null,
                          ),
                        );
                      }).toList(),
                    );
                  }),
                );
              }),
              const SizedBox(height: 16),
              _SettingsCard(
                title: l10n.notifications,
                subtitle: l10n.manageAlerts,
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      label: l10n.pushNotifications,
                      description: l10n.pushNotificationsDesc,
                      isOn: settingsStore.pushNotifications,
                      onChanged: () {
                        settingsStore.togglePushNotifications();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingsToggleRow(
                      label: l10n.emergencyAlerts,
                      description: l10n.emergencyAlertsDesc,
                      isOn: settingsStore.emergencyAlerts,
                      onChanged: () {
                        settingsStore.toggleEmergencyAlerts();
                        setState(() {});
                      },
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
                          isOn: settingsStore.visionRREnabled,
                          onChanged: () {
                            settingsStore.toggleVisionRR();
                            setState(() {});
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 80,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.cherry,
                              borderRadius: const BorderRadius.all(AppRadii.sm),
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
                      isOn: settingsStore.autoExport,
                      onChanged: () {
                        settingsStore.toggleAutoExport();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _ActionRow(
                      iconAsset: _settingsDownAsset,
                      title: l10n.exportAllData,
                      description: l10n.exportAllDataDesc,
                      onTap: () => _showExportDataDialog(context),
                    ),
                    const SizedBox(height: 12),
                    _ActionRow(
                      iconAsset: _settingsShareAsset,
                      title: l10n.shareWithVet,
                      description: l10n.shareWithVetDesc,
                      onTap: canManageActivePet
                          ? () => _showShareWithVetDialog(context)
                          : null,
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
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showSignOutDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.cherry.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.all(AppRadii.medium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 18, color: c.cherry),
                      const SizedBox(width: 8),
                      Text(
                        l10n.signOut,
                        style: AppTextStyles.body.copyWith(
                          color: c.cherry,
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

  void _showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.medium)),
        title: Text(l10n.signOut, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
        content: Text(l10n.signOutConfirmation, style: AppTextStyles.body.copyWith(color: c.chocolate)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onClose != null) widget.onClose!();
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
            },
            style: TextButton.styleFrom(backgroundColor: c.cherry),
            child: Text(l10n.signOut, style: TextStyle(color: c.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final user = userStore.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final photoCtrl = TextEditingController(text: user?.avatarUrl ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.white,
            borderRadius: const BorderRadius.vertical(top: AppRadii.medium),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.editProfile, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.displayName,
                  filled: true, fillColor: c.offWhite,
                  border: OutlineInputBorder(borderRadius: const BorderRadius.all(AppRadii.small), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: photoCtrl,
                decoration: InputDecoration(
                  labelText: l10n.profilePhoto,
                  filled: true, fillColor: c.offWhite,
                  border: OutlineInputBorder(borderRadius: const BorderRadius.all(AppRadii.small), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      if (user != null) {
                        userStore.setUser(user.copyWith(
                          name: nameCtrl.text.isNotEmpty ? nameCtrl.text : user.name,
                          avatarUrl: photoCtrl.text.isNotEmpty ? photoCtrl.text : user.avatarUrl,
                        ));
                      }
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.profileUpdated)),
                      );
                    },
                    style: TextButton.styleFrom(backgroundColor: c.lightBlue),
                    child: Text(l10n.save, style: TextStyle(color: c.chocolate)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRemoveMember(BuildContext context, String petName, String memberName) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.medium)),
        title: Text(l10n.removeMember, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
        content: Text(l10n.removeMemberConfirmation(memberName), style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await petStore.removeCareCircleMemberWithFirestore(petName, memberName);
              setState(() {});
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.memberRemoved)),
                );
              }
            },
            style: TextButton.styleFrom(backgroundColor: c.cherry),
            child: Text(l10n.removeMember, style: TextStyle(color: c.white)),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final emailController = TextEditingController();
    String selectedRole = 'Member';
    final roles = ['Admin', 'Member', 'Viewer'];
    bool isSending = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.white,
              borderRadius: const BorderRadius.vertical(top: AppRadii.medium),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.invite, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: l10n.enterEmailAddress,
                    filled: true,
                    fillColor: c.offWhite,
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(AppRadii.small),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.role, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: c.offWhite,
                    borderRadius: const BorderRadius.all(AppRadii.small),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      dropdownColor: c.white,
                      style: AppTextStyles.body.copyWith(color: c.chocolate),
                      items: roles
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setSheetState(() => selectedRole = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: isSending ? null : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty) return;

                        if (kEnableFirebase) {
                          setSheetState(() => isSending = true);
                          final activePet = petStore.activePet;
                          if (activePet?.id == null) {
                            Navigator.pop(ctx);
                            return;
                          }
                          final careCircleRole = CareCirclePermissions.fromString(selectedRole.toLowerCase());
                          final token = await InvitationService.createInvitation(
                            petId: activePet!.id!,
                            petName: activePet.name,
                            invitedEmail: email,
                            role: careCircleRole,
                            invitedByUid: userStore.currentUserUid ?? '',
                            invitedByName: userStore.currentUserDisplayName ?? '',
                          );
                          Navigator.pop(ctx);
                          final link = 'https://petcircle.app/invite?token=$token';
                          await Clipboard.setData(ClipboardData(text: link));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.invitationSentTo(email, selectedRole))),
                            );
                          }
                        } else {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.invitationSentTo(email, selectedRole))),
                          );
                        }
                      },
                      style: TextButton.styleFrom(backgroundColor: c.lightBlue),
                      child: isSending
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.chocolate))
                          : Text(l10n.sendInvite, style: TextStyle(color: c.chocolate)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.medium)),
        title: Text(l10n.exportAllData, style: AppTextStyles.heading3),
        content: Text(
          l10n.exportAllDataConfirmation,
          style: AppTextStyles.body.copyWith(color: c.chocolate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.exportStarted), backgroundColor: c.lightBlue),
              );
            },
            style: TextButton.styleFrom(backgroundColor: c.lightBlue),
            child: Text(l10n.exportAllData, style: TextStyle(color: c.chocolate)),
          ),
        ],
      ),
    );
  }

  void _showShareWithVetDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final emailController = TextEditingController();

    // 0 = idle, 1 = looking up, 2 = found vet, 3 = not a vet, 4 = not found, 5 = sending, 6 = error
    int state = 0;
    String? errorMessage;
    AppUser? foundVet;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: c.white,
              borderRadius: const BorderRadius.vertical(top: AppRadii.medium),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_hospital, size: 20, color: c.blue),
                    const SizedBox(width: AppSpacing.sm),
                    Text(l10n.inviteYourVet,
                        style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.inviteYourVetDesc, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'vet@clinic.com',
                          filled: true,
                          fillColor: c.offWhite,
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(AppRadii.small),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.blue,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(AppRadii.small),
                          ),
                        ),
                        onPressed: state == 1 ? null : () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty) return;
                          setSheetState(() { state = 1; errorMessage = null; });

                          if (!kEnableFirebase) {
                            setSheetState(() { state = 4; foundVet = null; });
                            return;
                          }

                          final vet = await UserService.findVetByEmail(email);
                          if (vet != null) {
                            setSheetState(() { state = 2; foundVet = vet; });
                            return;
                          }
                          final user = await UserService.findUserByEmail(email);
                          setSheetState(() {
                            foundVet = null;
                            state = user != null ? 3 : 4;
                          });
                        },
                        child: Text(l10n.lookUpVet,
                            style: AppTextStyles.caption.copyWith(color: c.white)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Lookup feedback
                if (state == 1)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: c.blue),
                      ),
                    ),
                  ),

                if (state == 2) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: c.lightBlue.withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.all(AppRadii.xs),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: c.blue.withValues(alpha: 0.2),
                          child: Icon(Icons.verified, size: 18, color: c.blue),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.vetFound,
                                  style: AppTextStyles.caption.copyWith(color: c.blue)),
                              Text(foundVet?.displayName ?? emailController.text,
                                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                if (state == 3)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: c.cherry.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.all(AppRadii.xs),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18, color: c.cherry),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(l10n.notAVetAccount,
                              style: AppTextStyles.caption.copyWith(color: c.cherry)),
                        ),
                      ],
                    ),
                  ),

                if (state == 4)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: c.lightYellow.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.all(AppRadii.xs),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: c.chocolate),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(l10n.vetNotFound,
                              style: AppTextStyles.caption.copyWith(color: c.chocolate)),
                        ),
                      ],
                    ),
                  ),

                if (state == 6 && errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: c.cherry.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.all(AppRadii.xs),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 18, color: c.cherry),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(errorMessage!,
                              style: AppTextStyles.caption.copyWith(color: c.cherry)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (state == 2 || state == 4)
                      TextButton(
                        onPressed: state == 5 ? null : () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty) return;

                          if (kEnableFirebase) {
                            setSheetState(() => state = 5);
                            final activePet = petStore.activePet;
                            if (activePet?.id == null) {
                              Navigator.pop(ctx);
                              return;
                            }

                            final validationError = await InvitationService.validateVetInvitation(
                              petId: activePet!.id!,
                              email: email,
                              invitedByUid: userStore.currentUserUid ?? '',
                            );
                            if (validationError != null) {
                              String msg;
                              switch (validationError) {
                                case 'vetAlreadyInvited':
                                  msg = l10n.vetAlreadyInvited;
                                case 'maxVetsReached':
                                  msg = l10n.maxVetsReached;
                                case 'dailyInviteLimitReached':
                                  msg = l10n.dailyInviteLimitReached;
                                default:
                                  msg = validationError;
                              }
                              setSheetState(() { state = 6; errorMessage = msg; });
                              return;
                            }

                            await InvitationService.createInvitation(
                              petId: activePet.id!,
                              petName: activePet.name,
                              invitedEmail: email,
                              role: CareCircleRole.viewer,
                              invitedByUid: userStore.currentUserUid ?? '',
                              invitedByName: userStore.currentUserDisplayName ?? '',
                              type: InvitationType.vet,
                            );
                            Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.vetInviteSent(email))),
                              );
                            }
                          } else {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.vetInviteSent(email))),
                            );
                          }
                        },
                        style: TextButton.styleFrom(backgroundColor: c.blue),
                        child: state == 5
                            ? SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: c.white))
                            : Text(
                                state == 2 ? l10n.addAsVet : l10n.sendVetInvite,
                                style: TextStyle(color: c.white)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThresholdDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalController = TextEditingController(text: '${settingsStore.elevatedThreshold}');
    final alertController = TextEditingController(text: '${settingsStore.criticalThreshold}');

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
              borderRadius: const BorderRadius.vertical(top: AppRadii.medium),
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
                      borderRadius: const BorderRadius.all(AppRadii.small),
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
                      borderRadius: const BorderRadius.all(AppRadii.small),
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
                        final elevated = int.tryParse(normalController.text) ?? 30;
                        final critical = int.tryParse(alertController.text) ?? 40;
                        settingsStore.updateThresholds(elevated: elevated, critical: critical);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.thresholdsUpdated)),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: c.lightBlue,
                        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.small)),
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
          shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.medium)),
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
        borderRadius: const BorderRadius.all(AppRadii.medium),
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
    this.onChanged,
  });

  final String label;
  final String? description;
  final bool isOn;
  final String? iconAsset;
  final VoidCallback? onChanged;

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
          borderRadius: const BorderRadius.all(AppRadii.medium),
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
                borderRadius: const BorderRadius.all(AppRadii.xs),
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
          borderRadius: const BorderRadius.all(AppRadii.xs),
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
                  _settingsTrashAsset,
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap == null ? c.white.withValues(alpha: 0.7) : c.white,
          borderRadius: const BorderRadius.all(AppRadii.small),
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
                        color: onTap == null
                            ? c.chocolate.withValues(alpha: 0.5)
                            : c.chocolate,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.31,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: onTap == null
                            ? c.chocolate.withValues(alpha: 0.5)
                            : c.chocolate,
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
          borderRadius: const BorderRadius.all(AppRadii.small),
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

