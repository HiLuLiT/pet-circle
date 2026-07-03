import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_card.dart';
import 'package:pet_circle/widgets/app_dropdown.dart';
import 'package:pet_circle/widgets/app_input_decoration.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/status_badge.dart';

enum _VetLookupState { idle, loading, foundVet, notVet, notFound }

class OnboardingStep4 extends StatefulWidget {
  const OnboardingStep4({
    super.key,
    this.onBack,
    this.onComplete,
    this.onInviteAdded,
    this.onVetInvited,
    this.isSubmitting = false,
  });

  final VoidCallback? onBack;
  final VoidCallback? onComplete;
  final void Function(String email, String role)? onInviteAdded;
  final void Function(String email, String? vetName)? onVetInvited;
  final bool isSubmitting;

  @override
  State<OnboardingStep4> createState() => _OnboardingStep4State();
}

class _OnboardingStep4State extends State<OnboardingStep4>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // --- Care Circle state ---
  final _roles = const ['Admin', 'Member', 'Viewer'];
  final List<_InviteStatus> _invites = [];
  bool _roleOpen = false;
  String _selectedRole = 'Member';
  final _emailController = TextEditingController();
  late AnimationController _chevronController;

  // --- Vet invite state ---
  final _vetEmailController = TextEditingController();
  _VetLookupState _vetLookupState = _VetLookupState.idle;
  AppUser? _foundVet;
  final List<_VetInvite> _addedVets = [];
  static const _maxVets = 2;

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _vetEmailController.dispose();
    _chevronController.dispose();
    super.dispose();
  }

  // --- Vet lookup ---

  Future<void> _lookUpVet() async {
    final email = _vetEmailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _vetLookupState = _VetLookupState.loading);

    if (!kEnableFirebase) {
      // In mock mode, treat any email as "not found" and allow invite
      setState(() {
        _foundVet = null;
        _vetLookupState = _VetLookupState.notFound;
      });
      return;
    }

    final vet = await userStore.findVetByEmail(email);
    if (vet != null) {
      setState(() {
        _foundVet = vet;
        _vetLookupState = _VetLookupState.foundVet;
      });
      return;
    }

    final user = await userStore.findUserByEmail(email);
    setState(() {
      _foundVet = null;
      _vetLookupState =
          user != null ? _VetLookupState.notVet : _VetLookupState.notFound;
    });
  }

  void _addVet() {
    final email = _vetEmailController.text.trim();
    if (email.isEmpty || _addedVets.length >= _maxVets) return;

    final vetName = _foundVet?.displayName;
    setState(() {
      _addedVets.add(_VetInvite(email: email, vetName: vetName));
      _vetEmailController.clear();
      _vetLookupState = _VetLookupState.idle;
      _foundVet = null;
    });
    widget.onVetInvited?.call(email, vetName);
  }

  // --- Care circle ---

  void _toggleRoleDropdown() {
    setState(() {
      _roleOpen = !_roleOpen;
      if (_roleOpen) {
        _chevronController.forward();
      } else {
        _chevronController.reverse();
      }
    });
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _roleOpen = false;
    });
    _chevronController.reverse();
  }

  void _addToCareCircle() {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final message = email.isNotEmpty
        ? l10n.invitationSentTo(email, _selectedRole)
        : l10n.pleaseEnterEmailAddress;

    final c = AppSemanticColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              email.isNotEmpty ? Icons.check_circle : Icons.info_outline,
              color: c.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: email.isNotEmpty ? c.primary : c.error,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusCard),
        margin: const EdgeInsets.all(AppSpacingTokens.pcMd),
      ),
    );

    if (email.isNotEmpty) {
      setState(() {
        _invites.add(_InviteStatus(name: email, role: _selectedRole));
      });
      widget.onInviteAdded?.call(email, _selectedRole);
      _emailController.clear();
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    super.build(context);

    return OnboardingShell(
      title: l10n.setupPetProfile,
      stepLabel: l10n.onboardingStep(4, 4),
      progress: 1,
      onBack: widget.onBack,
      onNext: widget.onComplete,
      nextLabel: l10n.complete,
      isNextLoading: widget.isSubmitting,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Section A: Invite Your Vet --
          _buildVetSection(l10n, c),

          const SizedBox(height: AppSpacingTokens.pcLg),
          Divider(color: c.hairline),
          const SizedBox(height: AppSpacingTokens.pcLg),

          // -- Section B: Invite Care Circle (existing) --
          _buildCareCircleSection(l10n, c),
        ],
      ),
    );
  }

  Widget _buildVetSection(AppLocalizations l10n, AppSemanticColors c) {
    final canAddMore = _addedVets.length < _maxVets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_hospital, size: 20, color: c.primary),
            const SizedBox(width: AppSpacingTokens.pcSm),
            Text(l10n.inviteYourVet, style: AppSemanticTextStyles.headingH2),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.pcSm),
        Text(l10n.inviteYourVetDesc,
            style: AppSemanticTextStyles.pcBody.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacingTokens.pcMd),

        // Added vets list
        if (_addedVets.isNotEmpty) ...[
          ..._addedVets.map((vet) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacingTokens.pcSm),
                child: _VetInviteRow(invite: vet),
              )),
          const SizedBox(height: AppSpacingTokens.pcSm),
        ],

        // Input + lookup (only show when slots remain)
        if (canAddMore) ...[
          _VetEmailInput(
            controller: _vetEmailController,
            lookupState: _vetLookupState,
            onLookUp: _lookUpVet,
          ),
          const SizedBox(height: AppSpacingTokens.pcSm),

          // Lookup result feedback
          _buildVetLookupFeedback(l10n, c),
        ] else
          Container(
            padding: const EdgeInsets.all(AppSpacingTokens.pcSm),
            decoration: BoxDecoration(
              color: c.accentButterTile,
              borderRadius: AppRadiiTokens.borderRadiusCard,
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: c.textSecondary),
                const SizedBox(width: AppSpacingTokens.pcSm),
                Expanded(
                  child: Text(
                    l10n.maxVetsReached,
                    style: AppSemanticTextStyles.pcCaption,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVetLookupFeedback(AppLocalizations l10n, AppSemanticColors c) {
    switch (_vetLookupState) {
      case _VetLookupState.idle:
        return const SizedBox.shrink();

      case _VetLookupState.loading:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.pcSm),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.primary,
              ),
            ),
          ),
        );

      case _VetLookupState.foundVet:
        return AppCard(
          padding: const EdgeInsets.all(AppSpacingTokens.pcSm),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: c.primaryLightest,
                child: Icon(Icons.verified, size: 18, color: c.primary),
              ),
              const SizedBox(width: AppSpacingTokens.pcSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.vetFound,
                        style: AppSemanticTextStyles.pcCaption
                            .copyWith(color: c.primary)),
                    Text(
                      _foundVet?.displayName ?? _vetEmailController.text,
                      style: AppSemanticTextStyles.pcBodyBold,
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                variant: PrimaryButtonVariant.miniPrimary,
                label: l10n.addAsVet,
                onPressed: _addVet,
              ),
            ],
          ),
        );

      case _VetLookupState.notVet:
        return Container(
          padding: const EdgeInsets.all(AppSpacingTokens.pcSm),
          decoration: BoxDecoration(
            color: c.accentBlushTile,
            borderRadius: AppRadiiTokens.borderRadiusCard,
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: c.error),
              const SizedBox(width: AppSpacingTokens.pcSm),
              Expanded(
                child: Text(
                  l10n.notAVetAccount,
                  style: AppSemanticTextStyles.pcCaption.copyWith(color: c.error),
                ),
              ),
            ],
          ),
        );

      case _VetLookupState.notFound:
        return Container(
          padding: const EdgeInsets.all(AppSpacingTokens.pcSm),
          decoration: BoxDecoration(
            color: c.accentButterTile,
            borderRadius: AppRadiiTokens.borderRadiusCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: c.textSecondary),
                  const SizedBox(width: AppSpacingTokens.pcSm),
                  Expanded(
                    child: Text(
                      l10n.vetNotFound,
                      style: AppSemanticTextStyles.pcCaption,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.pcSm),
              PrimaryButton(
                label: l10n.sendVetInvite,
                onPressed: _addVet,
              ),
            ],
          ),
        );
    }
  }

  Widget _buildCareCircleSection(AppLocalizations l10n, AppSemanticColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.inviteYourCareCircle, style: AppSemanticTextStyles.headingH2),
        const SizedBox(height: AppSpacingTokens.pcSm),
        Text(l10n.inviteCareCircleDescription,
            style: AppSemanticTextStyles.pcBody.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacingTokens.pcMd),
        if (_invites.isNotEmpty) ...[
          ..._invites.map((invite) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacingTokens.pcSm),
                child: _InviteRow(invite: invite),
              )),
          const SizedBox(height: AppSpacingTokens.pcSm),
        ],
        _InputRow(
          label: l10n.emailAddress,
          hint: l10n.enterYourEmail,
          controller: _emailController,
        ),
        const SizedBox(height: AppSpacingTokens.pcMd),
        _SelectRow(
          label: l10n.role,
          value: _selectedRole,
          isOpen: _roleOpen,
          chevronController: _chevronController,
          onTap: _toggleRoleDropdown,
          options: _roles,
          onOptionSelected: _selectRole,
        ),
        const SizedBox(height: AppSpacingTokens.pcMd),
        PrimaryButton(
          label: l10n.addToCareCircle,
          icon: Icons.person_add_alt_1,
          onPressed: _addToCareCircle,
        ),
      ],
    );
  }
}

// --- Helper models ---

class _InviteStatus {
  const _InviteStatus({required this.name, required this.role});
  final String name;
  final String role;
}

class _VetInvite {
  const _VetInvite({required this.email, this.vetName});
  final String email;
  final String? vetName;
}

// --- Shared widgets ---

class _VetInviteRow extends StatelessWidget {
  const _VetInviteRow({required this.invite});
  final _VetInvite invite;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.local_hospital, color: c.primary, size: 18),
          const SizedBox(width: AppSpacingTokens.pcSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.vetName ?? invite.email,
                  style: AppSemanticTextStyles.pcBody,
                  overflow: TextOverflow.ellipsis,
                ),
                if (invite.vetName != null)
                  Text(
                    invite.email,
                    style: AppSemanticTextStyles.pcCaptionMuted,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  l10n.pending,
                  style: AppSemanticTextStyles.pcCaptionMuted,
                ),
              ],
            ),
          ),
          StatusBadge(label: l10n.veterinarian, status: StatusBadgeStatus.normal),
        ],
      ),
    );
  }
}

class _VetEmailInput extends StatelessWidget {
  const _VetEmailInput({
    required this.controller,
    required this.lookupState,
    required this.onLookUp,
  });

  final TextEditingController controller;
  final _VetLookupState lookupState;
  final VoidCallback onLookUp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.emailAddress, style: AppSemanticTextStyles.labelMSemibold),
        const SizedBox(height: AppSpacingTokens.pcSm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => onLookUp(),
                decoration: appInputDecoration(
                  context,
                  hintText: l10n.hintVetEmail,
                ),
                style: AppSemanticTextStyles.pcBody,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.pcSm),
            PrimaryButton(
              variant: PrimaryButtonVariant.miniPrimary,
              label: l10n.lookUpVet,
              onPressed: lookupState == _VetLookupState.loading ? null : onLookUp,
            ),
          ],
        ),
      ],
    );
  }
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.invite});

  final _InviteStatus invite;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.mail_outline, color: c.primaryLight, size: 18),
          const SizedBox(width: AppSpacingTokens.pcSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.name,
                  style: AppSemanticTextStyles.pcBody,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.pending,
                  style: AppSemanticTextStyles.pcCaptionMuted,
                ),
              ],
            ),
          ),
          StatusBadge(label: invite.role, status: StatusBadgeStatus.normal),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppSemanticTextStyles.labelMSemibold),
        const SizedBox(height: AppSpacingTokens.pcSm),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: appInputDecoration(
            context,
            hintText: hint,
          ),
          style: AppSemanticTextStyles.pcBody,
        ),
      ],
    );
  }
}

/// Care-circle role selector. Thin wrapper over the shared [AppDropdown]
/// design-system widget: it forwards the label, current value, open state,
/// chevron animation, options, and selection callback. The open/close state
/// and selection are owned by the parent (see [_OnboardingStep4State]).
class _SelectRow extends StatelessWidget {
  const _SelectRow({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isOpen,
    required this.chevronController,
    required this.options,
    required this.onOptionSelected,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isOpen;
  final AnimationController chevronController;
  final List<String> options;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return AppDropdown(
      label: label,
      value: value,
      onTap: onTap,
      isOpen: isOpen,
      chevronController: chevronController,
      options: options,
      onOptionSelected: onOptionSelected,
    );
  }
}
