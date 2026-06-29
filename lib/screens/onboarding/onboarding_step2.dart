import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_dropdown.dart';
import 'package:pet_circle/widgets/note_callout.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep2 extends StatefulWidget {
  const OnboardingStep2({super.key, this.onBack, this.onNext, this.nextLabel, this.onClose, this.onDiagnosisChanged, this.initialDiagnosis});

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final VoidCallback? onClose;
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
    super.build(context);
    return OnboardingShell(
      title: l10n.setupPetProfile,
      stepLabel: l10n.onboardingStep(2, 3),
      progress: 0.66,
      onBack: widget.onBack,
      onNext: widget.onNext,
      nextLabel: widget.nextLabel,
      onClose: widget.onClose,
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
          AppDropdown(
            label: l10n.diagnosisOptional,
            value: _selectedDiagnosis,
            placeholder: l10n.selectDiagnosis,
            onTap: _toggleDropdown,
            isOpen: _isOpen,
            chevronController: _chevronController,
            options: _diagnoses,
            onOptionSelected: (diagnosis) {
              setState(() {
                _selectedDiagnosis = diagnosis;
                _isOpen = false;
              });
              _chevronController.reverse();
              widget.onDiagnosisChanged?.call(diagnosis);
            },
          ),
          const SizedBox(height: AppSpacingTokens.md),
          NoteCallout(
            title: l10n.note,
            body: l10n.diagnosisNote,
          ),
        ],
      ),
    );
  }
}
