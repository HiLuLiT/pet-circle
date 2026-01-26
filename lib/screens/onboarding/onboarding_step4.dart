import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep4 extends StatefulWidget {
  const OnboardingStep4({super.key, this.onBack, this.onComplete});

  final VoidCallback? onBack;
  final VoidCallback? onComplete;

  @override
  State<OnboardingStep4> createState() => _OnboardingStep4State();
}

class _OnboardingStep4State extends State<OnboardingStep4>
    with SingleTickerProviderStateMixin {
  static const _primaryBlue = Color(0xFF146FD9);
  final _roles = const [
    'Viewer (View Only)',
    'Caregiver',
    'Owner',
  ];
  final _invites = const [
    _InviteStatus(name: 'Guest 01', status: 'Status: invited'),
  ];
  bool _roleOpen = false;
  String _selectedRole = 'Viewer (View Only)';
  final _emailController = TextEditingController();
  late AnimationController _chevronController;

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
    _chevronController.dispose();
    super.dispose();
  }

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
    final email = _emailController.text.trim();
    final message = email.isNotEmpty
        ? 'Invitation sent to $email as $_selectedRole'
        : 'Please enter an email address';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              email.isNotEmpty ? Icons.check_circle : Icons.info_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            email.isNotEmpty ? AppColors.successGreen : AppColors.warningAmber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    if (email.isNotEmpty) {
      _emailController.clear();
      widget.onComplete?.call();
    }
  }

  void _resetInvite() {
    setState(() {
      _roleOpen = false;
      _selectedRole = _roles.first;
      _emailController.clear();
    });
    _chevronController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Setup pet profile',
      stepLabel: 'Step 4 of 4',
      progress: 1,
      onBack: widget.onBack,
      onNext: widget.onComplete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Invite Your Care Circle', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Invite family members, pet sitters, and veterinarians to collaborate.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          if (_invites.isNotEmpty) ...[
            _InviteRow(invite: _invites.first),
            const SizedBox(height: AppSpacing.md),
          ],
          _InputRow(
            label: 'Email Address',
            hint: 'email@example.com',
            controller: _emailController,
          ),
          const SizedBox(height: AppSpacing.md),
          _SelectRow(
            label: 'Role',
            value: _selectedRole,
            isOpen: _roleOpen,
            chevronController: _chevronController,
            onTap: _toggleRoleDropdown,
          ),
          if (_roleOpen)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
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
                        horizontal: 8,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.lightYellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
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
                backgroundColor: _primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(56),
                ),
              ),
              onPressed: _addToCareCircle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_alt_1,
                      size: 16, color: AppColors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Add to pet circle',
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onPressed: _resetInvite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_alt_1,
                      size: 16, color: _primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Add another pet circle',
                    style: AppTextStyles.body.copyWith(color: _primaryBlue),
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

class _InviteStatus {
  const _InviteStatus({required this.name, required this.status});

  final String name;
  final String status;
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.invite});

  final _InviteStatus invite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(invite.name, style: AppTextStyles.body),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightYellow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              invite.status,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.burgundy,
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
              fillColor: AppColors.white,
              hintText: hint,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.burgundy.withOpacity(0.4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4),
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
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.burgundy,
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
