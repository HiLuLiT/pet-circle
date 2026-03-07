import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/theme/app_theme.dart';
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

    final c = AppColorsTheme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              email.isNotEmpty ? Icons.check_circle : Icons.info_outline,
              color: c.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: email.isNotEmpty ? c.lightBlue : c.cherry,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadii.small)),
        margin: const EdgeInsets.all(AppSpacing.md),
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
    final c = AppColorsTheme.of(context);
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
          // ── Section A: Invite Your Vet ──
          _buildVetSection(l10n, c),

          const SizedBox(height: AppSpacing.lg),
          Divider(color: c.chocolate.withValues(alpha: 0.1)),
          const SizedBox(height: AppSpacing.lg),

          // ── Section B: Invite Care Circle (existing) ──
          _buildCareCircleSection(l10n, c),
        ],
      ),
    );
  }

  Widget _buildVetSection(AppLocalizations l10n, AppColorsTheme c) {
    final canAddMore = _addedVets.length < _maxVets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_hospital, size: 20, color: c.blue),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.inviteYourVet, style: AppTextStyles.heading3),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.inviteYourVetDesc, style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.md),

        // Added vets list
        if (_addedVets.isNotEmpty) ...[
          ..._addedVets.map((vet) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _VetInviteRow(invite: vet),
              )),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Input + lookup (only show when slots remain)
        if (canAddMore) ...[
          _VetEmailInput(
            controller: _vetEmailController,
            lookupState: _vetLookupState,
            onLookUp: _lookUpVet,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Lookup result feedback
          _buildVetLookupFeedback(l10n, c),
        ] else
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
                  child: Text(
                    l10n.maxVetsReached,
                    style: AppTextStyles.caption
                        .copyWith(color: c.chocolate),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVetLookupFeedback(AppLocalizations l10n, AppColorsTheme c) {
    switch (_vetLookupState) {
      case _VetLookupState.idle:
        return const SizedBox.shrink();

      case _VetLookupState.loading:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.blue,
              ),
            ),
          ),
        );

      case _VetLookupState.foundVet:
        return Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
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
                        style: AppTextStyles.caption
                            .copyWith(color: c.blue)),
                    Text(
                      _foundVet?.displayName ?? _vetEmailController.text,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.blue,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadii.pill),
                    ),
                  ),
                  onPressed: _addVet,
                  child: Text(l10n.addAsVet,
                      style: AppTextStyles.caption.copyWith(color: c.white)),
                ),
              ),
            ],
          ),
        );

      case _VetLookupState.notVet:
        return Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
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
                child: Text(
                  l10n.notAVetAccount,
                  style: AppTextStyles.caption.copyWith(color: c.cherry),
                ),
              ),
            ],
          ),
        );

      case _VetLookupState.notFound:
        return Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: c.lightYellow.withValues(alpha: 0.5),
            borderRadius: const BorderRadius.all(AppRadii.xs),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: c.chocolate),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.vetNotFound,
                      style: AppTextStyles.caption
                          .copyWith(color: c.chocolate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 32,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.blue,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadii.pill),
                    ),
                  ),
                  onPressed: _addVet,
                  child: Text(l10n.sendVetInvite,
                      style: AppTextStyles.caption.copyWith(color: c.white)),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildCareCircleSection(AppLocalizations l10n, AppColorsTheme c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.inviteYourCareCircle, style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.inviteCareCircleDescription, style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.md),
        if (_invites.isNotEmpty) ...[
          ..._invites.map((invite) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _InviteRow(invite: invite),
              )),
          const SizedBox(height: AppSpacing.sm),
        ],
        _InputRow(
          label: l10n.emailAddress,
          hint: 'email@example.com',
          controller: _emailController,
        ),
        const SizedBox(height: AppSpacing.md),
        _SelectRow(
          label: l10n.role,
          value: _selectedRole,
          isOpen: _roleOpen,
          chevronController: _chevronController,
          onTap: _toggleRoleDropdown,
        ),
        if (_roleOpen)
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: c.white,
              borderRadius: const BorderRadius.all(AppRadii.xs),
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
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? c.lightYellow : Colors.transparent,
                      borderRadius: const BorderRadius.all(AppRadii.xs),
                    ),
                    child: Text(
                      role,
                      style: AppTextStyles.body.copyWith(
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
              backgroundColor: c.blue,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(AppRadii.pill),
              ),
            ),
            onPressed: _addToCareCircle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1, size: 16, color: c.white),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.addToCareCircle,
                  style: AppTextStyles.body.copyWith(color: c.white),
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
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.lightBlue.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(AppRadii.xs),
      ),
      child: Row(
        children: [
          Icon(Icons.local_hospital, color: c.blue, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.vetName ?? invite.email,
                  style: AppTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
                if (invite.vetName != null)
                  Text(
                    invite.email,
                    style: AppTextStyles.caption
                        .copyWith(color: c.chocolate.withValues(alpha: 0.5)),
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  l10n.pending,
                  style: AppTextStyles.caption
                      .copyWith(color: c.chocolate.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.blue.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.all(AppRadii.xs),
            ),
            child: Text(
              l10n.veterinarian,
              style: AppTextStyles.caption.copyWith(
                color: c.blue,
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
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.emailAddress,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
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
                    fillColor: c.white,
                    hintText: 'vet@clinic.com',
                    hintStyle: AppTextStyles.body
                        .copyWith(color: c.chocolate.withValues(alpha: 0.4)),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(AppRadii.xs),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                  ),
                  style: AppTextStyles.body,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.blue,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadii.xs),
                  ),
                ),
                onPressed:
                    lookupState == _VetLookupState.loading ? null : onLookUp,
                child: Text(l10n.lookUpVet,
                    style: AppTextStyles.caption.copyWith(color: c.white)),
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
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: const BorderRadius.all(AppRadii.xs),
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline, color: c.lightBlue, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.name,
                  style: AppTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.pending,
                  style: AppTextStyles.caption.copyWith(
                    color: c.chocolate.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.lightYellow,
              borderRadius: const BorderRadius.all(AppRadii.xs),
            ),
            child: Text(
              invite.role,
              style: AppTextStyles.caption.copyWith(
                color: c.chocolate,
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
    final c = AppColorsTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              filled: true,
              fillColor: c.white,
              hintText: hint,
              hintStyle: AppTextStyles.body.copyWith(
                color: c.chocolate.withValues(alpha: 0.4),
              ),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(AppRadii.xs),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            style: AppTextStyles.body,
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
    final c = AppColorsTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: c.white,
              borderRadius: const BorderRadius.all(AppRadii.xs),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: AppTextStyles.body),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(
                    CurvedAnimation(
                      parent: chevronController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: c.chocolate,
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
