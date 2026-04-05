import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/services/invitation_service.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/user_avatar.dart';

class CircleScreen extends StatelessWidget {
  const CircleScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: petStore,
      builder: (context, _) {
        final pet = petStore.activePet;
        if (pet == null) return const _EmptyNoPet();
        return _CircleContent(
          petName: pet.name,
          members: pet.careCircle,
          pendingInvites: pet.pendingInvites,
        );
      },
    );

    if (!showScaffold) return body;

    final c = AppSemanticColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(child: body),
    );
  }
}

class _EmptyNoPet extends StatelessWidget {
  const _EmptyNoPet();

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 48, color: c.textTertiary),
          const SizedBox(height: AppSpacingTokens.md),
          Text(
            l10n.noPetsYet,
            style: AppSemanticTextStyles.title3.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _CircleContent extends StatelessWidget {
  const _CircleContent({
    required this.petName,
    required this.members,
    this.pendingInvites = const [],
  });

  final String petName;
  final List<CareCircleMember> members;
  final List<PendingInvite> pendingInvites;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isOwner = petStore.accessForActivePet().canManageCircle;

    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.people, size: 24, color: c.primary),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Text(
                  l10n.circleTitle(petName),
                  style: AppSemanticTextStyles.title3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.sm,
                  vertical: AppSpacingTokens.xs,
                ),
                decoration: BoxDecoration(
                  color: c.primaryLightest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${members.length}',
                  style: AppSemanticTextStyles.caption.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacingTokens.lg),

          // Member list or empty state
          if (members.length <= 1 && pendingInvites.isEmpty)
            _EmptyCircle(petName: petName, isOwner: isOwner)
          else
            Expanded(
              child: ListView(
                children: [
                  ...members.map((member) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
                    child: _MemberTile(
                      member: member,
                      isOwner: isOwner,
                      onRemove: isOwner && member.role != CareCircleRole.owner
                          ? () => _confirmRemove(context, member)
                          : null,
                    ),
                  )),
                  if (pendingInvites.isNotEmpty) ...[
                    const SizedBox(height: AppSpacingTokens.lg),
                    Text(
                      l10n.pendingInvites,
                      style: AppSemanticTextStyles.headingLg,
                    ),
                    const SizedBox(height: AppSpacingTokens.sm),
                    ...pendingInvites.map((invite) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.sm,
                      ),
                      child: _PendingInviteTile(
                        email: invite.invitedEmail,
                        expiresAt: invite.expiresAt,
                        onCancel: isOwner
                            ? () => _cancelInvite(context, invite.token)
                            : null,
                      ),
                    )),
                  ],
                ],
              ),
            ),

          // Invite button (owner only)
          if (isOwner)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacingTokens.md),
                child: PrimaryButton(
                  label: l10n.inviteToCircle,
                  icon: Icons.person_add_alt_1,
                  onPressed: () => _showInviteSheet(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, CareCircleMember member) async {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text(l10n.removeMember),
        content: Text(l10n.removeMemberConfirm(member.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.remove, style: TextStyle(color: c.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await petStore.removeCareCircleMemberWithFirestore(petName, member.name);
    }
  }

  Future<void> _cancelInvite(BuildContext context, String token) async {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text(l10n.cancelInvite),
        content: Text(l10n.cancelInvite),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.remove, style: TextStyle(color: c.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && kEnableFirebase) {
      await InvitationService.cancelInvitation(token);
    }
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteSheet(petName: petName),
    );
  }
}

class _EmptyCircle extends StatelessWidget {
  const _EmptyCircle({required this.petName, required this.isOwner});

  final String petName;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_add, size: 64, color: c.primaryLight),
            const SizedBox(height: AppSpacingTokens.md),
            Text(
              l10n.circleEmptyTitle,
              style: AppSemanticTextStyles.headingLg,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xl),
              child: Text(
                l10n.circleEmptyDescription(petName),
                style: AppSemanticTextStyles.body.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            if (isOwner) ...[
              const SizedBox(height: AppSpacingTokens.lg),
              PrimaryButton(
                label: l10n.inviteToCircle,
                icon: Icons.person_add_alt_1,
                onPressed: () => _showInviteSheet(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteSheet(petName: petName),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isOwner,
    this.onRemove,
  });

  final CareCircleMember member;
  final bool isOwner;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final isOwnerRole = member.role == CareCircleRole.owner;

    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          UserAvatar(
            name: member.name,
            imageUrl: member.avatarUrl,
            size: 40,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppSemanticTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  member.roleLabel,
                  style: AppSemanticTextStyles.caption.copyWith(
                    color: isOwnerRole ? c.textPrimary : c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isOwnerRole)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.sm,
                vertical: AppSpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: c.primaryLightest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                member.roleLabel,
                style: AppSemanticTextStyles.caption.copyWith(
                  color: c.primary,
                  fontSize: 10,
                ),
              ),
            ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: c.textTertiary),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

class _PendingInviteTile extends StatelessWidget {
  const _PendingInviteTile({
    required this.email,
    required this.expiresAt,
    this.onCancel,
  });

  final String email;
  final DateTime expiresAt;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final daysLeft = expiresAt.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.divider, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: c.primaryLightest,
            child: Icon(Icons.mail_outline, size: 20, color: c.primary),
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: AppSemanticTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.invitePending} · ${daysLeft}d',
                  style: AppSemanticTextStyles.caption.copyWith(
                    color: c.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              child: Text(
                l10n.cancelInvite,
                style: AppSemanticTextStyles.caption.copyWith(color: c.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet({required this.petName});

  final String petName;

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _successToken;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (!kEnableFirebase) {
      // Mock mode — simulate success with brief delay for UX
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successToken = 'mock-token';
      });
      return;
    }

    final pet = petStore.activePet;
    if (pet?.id == null) {
      setState(() {
        _isLoading = false;
        _error = 'No active pet';
      });
      return;
    }

    try {
      final validationError = await InvitationService.validateInvitation(
        petId: pet!.id!,
        email: email,
        invitedByUid: userStore.currentUserUid ?? '',
      );

      if (validationError != null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = validationError;
        });
        return;
      }

      final token = await InvitationService.createInvitation(
        petId: pet.id!,
        petName: pet.name,
        invitedEmail: email,
        invitedByUid: userStore.currentUserUid ?? '',
        invitedByName: userStore.currentUserDisplayName ?? '',
      );

      final link = 'https://petcircle.app/invite?token=$token';
      await Clipboard.setData(ClipboardData(text: link));

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successToken = token;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to send invite. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacingTokens.lg,
        top: AppSpacingTokens.lg,
        left: AppSpacingTokens.lg,
        right: AppSpacingTokens.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          Text(
            l10n.inviteToCircle,
            style: AppSemanticTextStyles.title3,
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.inviteDescription(widget.petName),
            style: AppSemanticTextStyles.body.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacingTokens.lg),

          if (_successToken != null)
            _InviteSuccess(petName: widget.petName)
          else ...[
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: c.surface,
                hintText: 'email@example.com',
                hintStyle: AppSemanticTextStyles.body.copyWith(color: c.textTertiary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: c.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: c.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: AppSemanticTextStyles.body,
              onSubmitted: (_) => _sendInvite(),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                _error!,
                style: AppSemanticTextStyles.caption.copyWith(color: c.error),
              ),
            ],
            const SizedBox(height: AppSpacingTokens.md),
            PrimaryButton(
              label: l10n.sendInvite,
              icon: Icons.send,
              onPressed: _isLoading ? null : _sendInvite,
            ),
          ],
        ],
      ),
    );
  }
}

class _InviteSuccess extends StatelessWidget {
  const _InviteSuccess({required this.petName});

  final String petName;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: c.primaryLightest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: c.primary, size: 40),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.inviteSent,
            style: AppSemanticTextStyles.headingLg,
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          Text(
            l10n.inviteLinkCopied,
            style: AppSemanticTextStyles.body.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          PrimaryButton(
            label: l10n.done,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
