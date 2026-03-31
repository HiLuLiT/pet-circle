import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep2 extends StatefulWidget {
  const OnboardingStep2({super.key, this.onBack, this.onNext, this.nextLabel, this.onDiagnosisChanged, this.initialDiagnosis});

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final ValueChanged<String>? onDiagnosisChanged;
  final String? initialDiagnosis;

  @override
  State<OnboardingStep2> createState() => _OnboardingStep2State();
}

class _OnboardingStep2State extends State<OnboardingStep2>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
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
    _selectedDiagnosis = widget.initialDiagnosis?.isNotEmpty == true ? widget.initialDiagnosis : null;
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
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    super.build(context);
    return OnboardingShell(
      title: l10n.setupPetProfile,
      stepLabel: l10n.onboardingStep(2, 4),
      progress: 0.5,
      onBack: widget.onBack,
      onNext: widget.onNext,
      nextLabel: widget.nextLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.medicalInformation, style: AppSemanticTextStyles.headingLg),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.medicalInfoDescription,
            style: AppSemanticTextStyles.body,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Text(
            l10n.diagnosisOptional,
            style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: AppRadiiTokens.borderRadiusLg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedDiagnosis ?? l10n.selectDiagnosis,
                      style: AppSemanticTextStyles.body.copyWith(
                        color: _selectedDiagnosis == null
                            ? c.textTertiary
                            : c.textPrimary,
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
          if (_isOpen)
            Container(
              margin: const EdgeInsets.only(top: AppSpacingTokens.sm),
              padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: AppRadiiTokens.borderRadiusLg,
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
                      widget.onDiagnosisChanged?.call(diagnosis);
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
                        diagnosis,
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
          const SizedBox(height: AppSpacingTokens.md),
          Container(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: AppRadiiTokens.borderRadiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.note,
                  style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                Text(
                  l10n.diagnosisNote,
                  style: AppSemanticTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
