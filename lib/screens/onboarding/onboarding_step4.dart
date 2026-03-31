import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

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

    final vet = await UserService.findVetByEmail(email);
    if (vet != null) {
      setState(() {
        _foundVet = vet;
        _vetLookupState = _VetLookupState.foundVet;
      });
      return;
    }

    final user = await UserService.findUserByEmail(email);
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
        backgroundColor: email.isNotEmpty ? c.info : c.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadiiTokens.borderRadiusSm),
        margin: const EdgeInsets.all(AppSpacingTokens.md),
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

          const SizedBox(height: AppSpacingTokens.lg),
          Divider(color: c.divider),
          const SizedBox(height: AppSpacingTokens.lg),

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
            Icon(Icons.local_hospital, size: 20, color: c.info),
            const SizedBox(width: AppSpacingTokens.sm),
            Text(l10n.inviteYourVet, style: AppSemanticTextStyles.headingLg),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Text(l10n.inviteYourVetDesc, style: AppSemanticTextStyles.body),
        const SizedBox(height: AppSpacingTokens.md),

        // Added vets list
        if (_addedVets.isNotEmpty) ...[
          ..._addedVets.map((vet) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
                child: _VetInviteRow(invite: vet),
              )),
          const SizedBox(height: AppSpacingTokens.sm),
        ],

        // Input + lookup (only show when slots remain)
        if (canAddMore) ...[
          _VetEmailInput(
            controller: _vetEmailController,
            lookupState: _vetLookupState,
            onLookUp: _lookUpVet,
          ),
          const SizedBox(height: AppSpacingTokens.sm),

          // Lookup result feedback
          _buildVetLookupFeedback(l10n, c),
        ] else
          Container(
            padding: const EdgeInsets.all(AppSpacingTokens.sm),
            decoration: BoxDecoration(
              color: c.warning.withValues(alpha: 0.15),
              borderRadius: AppRadiiTokens.borderRadiusLg,
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: c.textSecondary),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.maxVetsReached,
                    style: AppSemanticTextStyles.caption
                        .copyWith(color: c.textSecondary),
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.info,
              ),
            ),
          ),
        );

      case _VetLookupState.foundVet:
        return Container(
          margin: const EdgeInsets.only(top: AppSpacingTokens.sm),
          padding: const EdgeInsets.all(AppSpacingTokens.sm),
          decoration: BoxDecoration(
            color: c.info.withValues(alpha: 0.15),
            borderRadius: AppRadiiTokens.borderRadiusLg,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: c.info.withValues(alpha: 0.2),
                child: Icon(Icons.verified, size: 18, color: c.info),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.vetFound,
                        style: AppSemanticTextStyles.caption
                            .copyWith(color: c.info)),
                    Text(
                      _foundVet?.displayName ?? _vetEmailController.text,
                      style: AppSemanticTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.info,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadiiTokens.borderRadiusFull,
                    ),
                  ),
                  onPressed: _addVet,
                  child: Text(l10n.addAsVet,
                      style: AppSemanticTextStyles.caption.copyWith(color: c.onPrimary)),
                ),
              ),
            ],
          ),
        );

      case _VetLookupState.notVet:
        return Container(
          margin: const EdgeInsets.only(top: AppSpacingTokens.sm),
          padding: const EdgeInsets.all(AppSpacingTokens.sm),
          decoration: BoxDecoration(
            color: c.error.withValues(alpha: 0.1),
            borderRadius: AppRadiiTokens.borderRadiusLg,
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: c.error),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Text(
                  l10n.notAVetAccount,
                  style: AppSemanticTextStyles.caption.copyWith(color: c.error),
                ),
              ),
            ],
          ),
        );

      case _VetLookupState.notFound:
        return Container(
          margin: const EdgeInsets.only(top: AppSpacingTokens.sm),
          padding: const EdgeInsets.all(AppSpacingTokens.sm),
          decoration: BoxDecoration(
            color: c.warning.withValues(alpha: 0.15),
            borderRadius: AppRadiiTokens.borderRadiusLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: c.textSecondary),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: Text(
                      l10n.vetNotFound,
                      style: AppSemanticTextStyles.caption
                          .copyWith(color: c.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              SizedBox(
                height: 32,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.info,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadiiTokens.borderRadiusFull,
                    ),
                  ),
                  onPressed: _addVet,
                  child: Text(l10n.sendVetInvite,
                      style: AppSemanticTextStyles.caption.copyWith(color: c.onPrimary)),
                ),
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
        Text(l10n.inviteYourCareCircle, style: AppSemanticTextStyles.headingLg),
        const SizedBox(height: AppSpacingTokens.sm),
        Text(l10n.inviteCareCircleDescription, style: AppSemanticTextStyles.body),
        const SizedBox(height: AppSpacingTokens.md),
        if (_invites.isNotEmpty) ...[
          ..._invites.map((invite) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
                child: _InviteRow(invite: invite),
              )),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        _InputRow(
          label: l10n.emailAddress,
          hint: 'email@example.com',
          controller: _emailController,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _SelectRow(
          label: l10n.role,
          value: _selectedRole,
          isOpen: _roleOpen,
          chevronController: _chevronController,
          onTap: _toggleRoleDropdown,
        ),
        if (_roleOpen)
          Container(
            margin: const EdgeInsets.only(top: AppSpacingTokens.sm),
            padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: AppRadiiTokens.borderRadiusLg,
            ),
            child: Column(
              children: _roles.map((role) {
                final isSelected = role == _selectedRole;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = role;
                      _roleOpen = false;
                    });
                    _chevronController.reverse();
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.sm,
                      vertical: AppSpacingTokens.xs,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: AppSpacingTokens.sm,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? c.warning.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: AppRadiiTokens.borderRadiusLg,
                    ),
                    child: Text(
                      role,
                      style: AppSemanticTextStyles.body.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c.info,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadiiTokens.borderRadiusFull,
              ),
            ),
            onPressed: _addToCareCircle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1, size: 16, color: c.onPrimary),
                const SizedBox(width: AppSpacingTokens.sm),
                Text(
                  l10n.addToCareCircle,
                  style: AppSemanticTextStyles.body.copyWith(color: c.onPrimary),
                ),
              ],
            ),
          ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.info.withValues(alpha: 0.1),
        borderRadius: AppRadiiTokens.borderRadiusLg,
      ),
      child: Row(
        children: [
          Icon(Icons.local_hospital, color: c.info, size: 18),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.vetName ?? invite.email,
                  style: AppSemanticTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
                if (invite.vetName != null)
                  Text(
                    invite.email,
                    style: AppSemanticTextStyles.caption
                        .copyWith(color: c.textTertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  l10n.pending,
                  style: AppSemanticTextStyles.caption
                      .copyWith(color: c.textTertiary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm, vertical: AppSpacingTokens.xs),
            decoration: BoxDecoration(
              color: c.info.withValues(alpha: 0.15),
              borderRadius: AppRadiiTokens.borderRadiusLg,
            ),
            child: Text(
              l10n.veterinarian,
              style: AppSemanticTextStyles.caption.copyWith(
                color: c.info,
                fontSize: 10,
              ),
            ),
          ),
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
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.emailAddress,
            style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacingTokens.sm),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => onLookUp(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: c.surface,
                    hintText: 'vet@clinic.com',
                    hintStyle: AppSemanticTextStyles.body
                        .copyWith(color: c.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: AppRadiiTokens.borderRadiusLg,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                  ),
                  style: AppSemanticTextStyles.body,
                ),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.info,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadiiTokens.borderRadiusLg,
                  ),
                ),
                onPressed:
                    lookupState == _VetLookupState.loading ? null : onLookUp,
                child: Text(l10n.lookUpVet,
                    style: AppSemanticTextStyles.caption.copyWith(color: c.onPrimary)),
              ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadiiTokens.borderRadiusLg,
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline, color: c.primaryLight, size: 18),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.name,
                  style: AppSemanticTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.pending,
                  style: AppSemanticTextStyles.caption.copyWith(
                    color: c.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm, vertical: AppSpacingTokens.xs),
            decoration: BoxDecoration(
              color: c.warning.withValues(alpha: 0.2),
              borderRadius: AppRadiiTokens.borderRadiusLg,
            ),
            child: Text(
              invite.role,
              style: AppSemanticTextStyles.caption.copyWith(
                color: c.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
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
    final c = AppSemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacingTokens.sm),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              filled: true,
              fillColor: c.surface,
              hintText: hint,
              hintStyle: AppSemanticTextStyles.body.copyWith(
                color: c.textTertiary,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadiiTokens.borderRadiusLg,
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            style: AppSemanticTextStyles.body,
          ),
        ),
      ],
    );
  }
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isOpen,
    required this.chevronController,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isOpen;
  final AnimationController chevronController;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacingTokens.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: AppRadiiTokens.borderRadiusLg,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: AppSemanticTextStyles.body),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(
                    CurvedAnimation(
                      parent: chevronController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: c.textPrimary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
