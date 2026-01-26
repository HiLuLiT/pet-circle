import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep2 extends StatefulWidget {
  const OnboardingStep2({super.key, this.onBack, this.onNext});

  final VoidCallback? onBack;
  final VoidCallback? onNext;

  @override
  State<OnboardingStep2> createState() => _OnboardingStep2State();
}

class _OnboardingStep2State extends State<OnboardingStep2>
    with SingleTickerProviderStateMixin {
  final _diagnoses = const [
    'Diagnosis 01',
    'Diagnosis 02',
    'Diagnosis 03',
    'Diagnosis 04',
    'Diagnosis 05',
  ];
  String? _selectedDiagnosis;
  bool _isOpen = false;
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
    _chevronController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _chevronController.forward();
      } else {
        _chevronController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Setup pet profile',
      stepLabel: 'Step 2 of 4',
      progress: 0.5,
      onBack: widget.onBack,
      onNext: widget.onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Medical Information', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'This helps us provide more accurate monitoring recommendations.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Diagnosis (Optional)',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedDiagnosis ?? 'Select diagnosis',
                      style: AppTextStyles.body.copyWith(
                        color: _selectedDiagnosis == null
                            ? AppColors.burgundy.withOpacity(0.5)
                            : AppColors.burgundy,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(
                      CurvedAnimation(
                        parent: _chevronController,
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
          if (_isOpen)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: _diagnoses.map((diagnosis) {
                  final isSelected = diagnosis == _selectedDiagnosis;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDiagnosis = diagnosis;
                        _isOpen = false;
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
                        diagnosis,
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
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note:',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This information is used to set appropriate monitoring thresholds and is shared only with your care circle.',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
