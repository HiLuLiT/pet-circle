import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/invitation_service.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

import 'package:pet_circle/screens/settings/settings_content.dart';

/// Mixin that contains all dialog/bottom-sheet methods used by [SettingsContent].
///
/// Extracted to keep the main content file under the 800-line limit while
/// preserving access to [State] members ([setState], [mounted], [widget]).
mixin SettingsDialogsMixin on State<SettingsContent> {
  void showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusLg),
        title: Text(l10n.signOut, style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
        content: Text(l10n.signOutConfirmation, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (widget.onClose != null) widget.onClose!();
              await authProvider.signOut();
              if (!context.mounted) return;
              context.go(AppRoutes.welcome);
            },
            style: TextButton.styleFrom(backgroundColor: c.error),
            child: Text(l10n.signOut, style: TextStyle(color: c.background)),
          ),
        ],
      ),
    );
  }

  void showEditProfileDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
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
            color: c.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadiiTokens.lg)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.editProfile, style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.displayName,
                  filled: true, fillColor: c.surface,
                  border: OutlineInputBorder(borderRadius: AppRadiiTokens.borderRadiusSm, borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: photoCtrl,
                decoration: InputDecoration(
                  labelText: l10n.profilePhoto,
                  filled: true, fillColor: c.surface,
                  border: OutlineInputBorder(borderRadius: AppRadiiTokens.borderRadiusSm, borderSide: BorderSide.none),
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
                    style: TextButton.styleFrom(backgroundColor: c.primaryLight),
                    child: Text(l10n.save, style: TextStyle(color: c.textPrimary)),
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
    final c = AppSemanticColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusLg),
        title: Text(l10n.removeMember, style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
        content: Text(l10n.removeMemberConfirmation(memberName), style: AppSemanticTextStyles.body),
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
            style: TextButton.styleFrom(backgroundColor: c.error),
            child: Text(l10n.removeMember, style: TextStyle(color: c.background)),
          ),
        ],
      ),
    );
  }

  void showInviteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
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
              color: c.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadiiTokens.lg)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.invite, style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: l10n.enterEmailAddress,
                    filled: true,
                    fillColor: c.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppRadiiTokens.borderRadiusSm,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.role, style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacingTokens.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: AppRadiiTokens.borderRadiusSm,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      dropdownColor: c.background,
                      style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
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
                          final token = await InvitationService.createInvitation(
                            petId: activePet!.id!,
                            petName: activePet.name,
                            invitedEmail: email,
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
                      style: TextButton.styleFrom(backgroundColor: c.primaryLight),
                      child: isSending
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.textPrimary))
                          : Text(l10n.sendInvite, style: TextStyle(color: c.textPrimary)),
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
    final c = AppSemanticColors.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusLg),
        title: Text(l10n.exportAllData, style: AppSemanticTextStyles.headingLg),
        content: Text(
          l10n.exportAllDataConfirmation,
          style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
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
                SnackBar(content: Text(l10n.exportStarted), backgroundColor: c.primaryLight),
              );
            },
            style: TextButton.styleFrom(backgroundColor: c.primaryLight),
            child: Text(l10n.exportAllData, style: TextStyle(color: c.textPrimary)),
          ),
        ],
      ),
    );
  }

  void showShareWithVetDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
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
            padding: const EdgeInsets.all(AppSpacingTokens.lg),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadiiTokens.lg)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_hospital, size: 20, color: c.primary),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Text(l10n.inviteYourVet,
                        style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                Text(l10n.inviteYourVetDesc, style: AppSemanticTextStyles.body),
                const SizedBox(height: AppSpacingTokens.md),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'vet@clinic.com',
                          filled: true,
                          fillColor: c.surface,
                          border: OutlineInputBorder(
                            borderRadius: AppRadiiTokens.borderRadiusSm,
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadiiTokens.borderRadiusSm,
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
                            style: AppSemanticTextStyles.caption.copyWith(color: c.background)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacingTokens.sm),

                // Lookup feedback
                if (state == 1)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: c.primary),
                      ),
                    ),
                  ),

                if (state == 2) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: c.primaryLight.withValues(alpha: 0.15),
                      borderRadius: AppRadiiTokens.borderRadiusSm,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: c.primary.withValues(alpha: 0.2),
                          child: Icon(Icons.verified, size: 18, color: c.primary),
                        ),
                        const SizedBox(width: AppSpacingTokens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.vetFound,
                                  style: AppSemanticTextStyles.caption.copyWith(color: c.primary)),
                              Text(foundVet?.displayName ?? emailController.text,
                                  style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                ],

                if (state == 3)
                  Container(
                    padding: const EdgeInsets.all(AppSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: c.error.withValues(alpha: 0.1),
                      borderRadius: AppRadiiTokens.borderRadiusSm,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18, color: c.error),
                        const SizedBox(width: AppSpacingTokens.sm),
                        Expanded(
                          child: Text(l10n.notAVetAccount,
                              style: AppSemanticTextStyles.caption.copyWith(color: c.error)),
                        ),
                      ],
                    ),
                  ),

                if (state == 4)
                  Container(
                    padding: const EdgeInsets.all(AppSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: c.warning.withValues(alpha: 0.5),
                      borderRadius: AppRadiiTokens.borderRadiusSm,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: c.textPrimary),
                        const SizedBox(width: AppSpacingTokens.sm),
                        Expanded(
                          child: Text(l10n.vetNotFound,
                              style: AppSemanticTextStyles.caption.copyWith(color: c.textPrimary)),
                        ),
                      ],
                    ),
                  ),

                if (state == 6 && errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: c.error.withValues(alpha: 0.1),
                      borderRadius: AppRadiiTokens.borderRadiusSm,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 18, color: c.error),
                        const SizedBox(width: AppSpacingTokens.sm),
                        Expanded(
                          child: Text(errorMessage!,
                              style: AppSemanticTextStyles.caption.copyWith(color: c.error)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacingTokens.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
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

                            final validationError = await InvitationService.validateInvitation(
                              petId: activePet!.id!,
                              email: email,
                              invitedByUid: userStore.currentUserUid ?? '',
                            );
                            if (validationError != null) {
                              String msg;
                              switch (validationError) {
                                case 'alreadyInvited':
                                  msg = l10n.vetAlreadyInvited;
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
                              invitedByUid: userStore.currentUserUid ?? '',
                              invitedByName: userStore.currentUserDisplayName ?? '',
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
                        style: TextButton.styleFrom(backgroundColor: c.primary),
                        child: state == 5
                            ? SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: c.background))
                            : Text(
                                state == 2 ? l10n.addAsVet : l10n.sendVetInvite,
                                style: TextStyle(color: c.background)),
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
        final c = AppSemanticColors.of(context);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadiiTokens.lg)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.configureAlertThresholds, style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
                const SizedBox(height: 8),
                Text(l10n.configureAlertThresholdsDesc, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
                const SizedBox(height: 24),
                Text(l10n.normalThresholdBpm, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: normalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 30',
                    filled: true,
                    fillColor: c.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppRadiiTokens.borderRadiusSm,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.alertThresholdBpm, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: alertController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 40',
                    filled: true,
                    fillColor: c.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppRadiiTokens.borderRadiusSm,
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
                      child: Text(l10n.cancel, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
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
                        backgroundColor: c.primaryLight,
                        shape: RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusSm),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(l10n.save, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
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
        final c = AppSemanticColors.of(context);
        return AlertDialog(
          backgroundColor: c.background,
          shape: RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusLg),
          title: Text(title, style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
          content: SingleChildScrollView(
            child: Text(content, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
            ),
          ],
        );
      },
    );
  }
}
