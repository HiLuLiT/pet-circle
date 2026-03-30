import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/invitation.dart';
import 'package:pet_circle/services/invitation_service.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/app_theme.dart';

import 'package:pet_circle/screens/settings/settings_content.dart';

/// Mixin that contains all dialog/bottom-sheet methods used by [SettingsContent].
///
/// Extracted to keep the main content file under the 800-line limit while
/// preserving access to [State] members ([setState], [mounted], [widget]).
mixin SettingsDialogsMixin on State<SettingsContent> {
  void showSignOutDialog(BuildContext context) {
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
              context.go(AppRoutes.welcome);
            },
            style: TextButton.styleFrom(backgroundColor: c.cherry),
            child: Text(l10n.signOut, style: TextStyle(color: c.white)),
          ),
        ],
      ),
    );
  }

  void showEditProfileDialog(BuildContext context) {
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

  void confirmRemoveMember(BuildContext context, String petName, String memberName) {
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
            onPressed: () {
              Navigator.pop(ctx);
              petStore.removeCareCircleMemberWithFirestore(petName, memberName);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.memberRemoved)),
              );
            },
            style: TextButton.styleFrom(backgroundColor: c.cherry),
            child: Text(l10n.removeMember, style: TextStyle(color: c.white)),
          ),
        ],
      ),
    );
  }

  void showInviteDialog(BuildContext context) {
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
                          final navigator = Navigator.of(ctx);
                          final careCircleRole = CareCirclePermissions.fromString(selectedRole.toLowerCase());
                          final token = await InvitationService.createInvitation(
                            petId: activePet!.id!,
                            petName: activePet.name,
                            invitedEmail: email,
                            role: careCircleRole,
                            invitedByUid: userStore.currentUserUid ?? '',
                            invitedByName: userStore.currentUserDisplayName ?? '',
                          );
                          await notificationStore.addNotification(
                            AppNotification(
                              id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
                              title: l10n.careCircleUpdated,
                              body: l10n.invitationSentTo(email, selectedRole),
                              type: NotificationType.careCircle,
                              createdAt: DateTime.now(),
                              petName: activePet.name,
                            ),
                          );
                          navigator.pop();
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

  void showExportDataDialog(BuildContext context) {
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

  void showShareWithVetDialog(BuildContext context) {
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
                          final navigator = Navigator.of(ctx);

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
                            await notificationStore.addNotification(
                              AppNotification(
                                id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
                                title: l10n.careCircleUpdated,
                                body: l10n.vetInviteSent(email),
                                type: NotificationType.careCircle,
                                createdAt: DateTime.now(),
                                petName: activePet.name,
                              ),
                            );
                            navigator.pop();
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

  void showThresholdDialog(BuildContext context) {
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
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(this.context);
                        final elevated = int.tryParse(normalController.text) ?? 30;
                        final critical = int.tryParse(alertController.text) ?? 40;
                        settingsStore.updateThresholds(
                          elevated: elevated,
                          critical: critical,
                        );
                        navigator.pop();
                        messenger.showSnackBar(
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

  void showInfoDialog(BuildContext context, String title, String content) {
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
