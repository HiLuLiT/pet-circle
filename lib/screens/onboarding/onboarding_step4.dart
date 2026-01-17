import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

class OnboardingStep4 extends StatelessWidget {
  const OnboardingStep4({super.key, this.onBack, this.onComplete});

  final VoidCallback? onBack;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(),
              const SizedBox(height: AppSpacing.lg),
              const _InviteSection(),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1, color: AppColors.burgundy),
              const SizedBox(height: AppSpacing.md),
              _Footer(onBack: onBack, onComplete: onComplete),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Setup pet profile', style: AppTextStyles.heading2),
            ),
            Text('Step 4 of 4', style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 8,
            color: AppColors.burgundy.withOpacity(0.08),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 1,
                child: Container(color: AppColors.pink),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InviteSection extends StatefulWidget {
  const _InviteSection();

  @override
  State<_InviteSection> createState() => _InviteSectionState();
}

class _InviteSectionState extends State<_InviteSection>
    with SingleTickerProviderStateMixin {
  final _roles = const [
    'Viewer (View Only)',
    'Caregiver',
    'Owner',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Invite Your Care Circle', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Invite family members, pet sitters, and veterinarians to track SRR together.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _InputRow(
                label: 'Email Address',
                hint: 'email@example.com',
                controller: _emailController,
              ),
              const SizedBox(height: AppSpacing.md),
              _AnimatedSelectRow(
                label: 'Role',
                value: _selectedRole,
                isOpen: _roleOpen,
                chevronController: _chevronController,
                onTap: _toggleRoleDropdown,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _roleOpen
                    ? Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(12),
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
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFE8A8)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  role,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.md),
              _AddCareCircleButton(onPressed: _addToCareCircle),
            ],
          ),
        ),
      ],
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
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFE8A8),
              hintText: hint,
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.burgundy),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            ),
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}

class _AnimatedSelectRow extends StatelessWidget {
  const _AnimatedSelectRow({
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
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8A8),
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

class _AddCareCircleButton extends StatelessWidget {
  const _AddCareCircleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5B041),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add, size: 18, color: AppColors.burgundy),
            const SizedBox(width: 8),
            Text(
              'Add to Care Circle',
              style: AppTextStyles.body.copyWith(
                color: AppColors.burgundy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({this.onBack, this.onComplete});

  final VoidCallback? onBack;
  final VoidCallback? onComplete;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: AppColors.burgundy),
        ),
        TextButton(
          onPressed: onComplete,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.burgundy,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            children: [
              Text(
                'Complete setup',
                style: AppTextStyles.caption.copyWith(color: AppColors.white),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 14, color: AppColors.white),
            ],
          ),
        ),
      ],
    );
  }
}
