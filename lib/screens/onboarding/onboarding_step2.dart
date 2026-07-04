import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_input_decoration.dart';
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
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final TextEditingController _diagnosisController;

  @override
  void initState() {
    super.initState();
    _diagnosisController = TextEditingController(text: widget.initialDiagnosis ?? '');
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
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
          Text(l10n.medicalInformation, style: AppSemanticTextStyles.headingH2),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.medicalInfoDescription,
            style: AppSemanticTextStyles.labelLRegular.copyWith(
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.diagnosisLabel,
                style: AppSemanticTextStyles.labelMSemibold,
              ),
              const SizedBox(width: AppSpacingTokens.xs),
              Text(
                l10n.optionalSuffix,
                style: AppSemanticTextStyles.pcLabelMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          TextField(
            controller: _diagnosisController,
            style: AppSemanticTextStyles.pcBody,
            decoration: appInputDecoration(
              context,
              hintText: l10n.diagnosisHint,
            ),
            onChanged: widget.onDiagnosisChanged,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          NoteCallout(
            title: l10n.noteLabel,
            body: l10n.diagnosisNote,
          ),
        ],
      ),
    );
  }
}
