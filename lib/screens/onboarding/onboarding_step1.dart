import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/breed_search_field.dart';
import 'package:pet_circle/widgets/labeled_text_field.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep1 extends StatefulWidget {
  const OnboardingStep1({
    super.key,
    this.onNext,
    this.nextLabel,
    this.onClose,
    this.onNameChanged,
    this.onBreedChanged,
    this.onAgeChanged,
    this.onWeightChanged,
    this.initialName,
    this.initialBreed,
    this.initialAge,
    this.initialWeight,
  });

  final VoidCallback? onNext;
  final String? nextLabel;
  final VoidCallback? onClose;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onBreedChanged;
  final ValueChanged<String>? onAgeChanged;
  final ValueChanged<String>? onWeightChanged;
  final String? initialName;
  final String? initialBreed;
  final String? initialAge;
  final String? initialWeight;

  @override
  State<OnboardingStep1> createState() => _OnboardingStep1State();
}

class _OnboardingStep1State extends State<OnboardingStep1>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _ageController.text = widget.initialAge ?? '';
    _weightController.text = widget.initialWeight ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    return OnboardingShell(
      title: l10n.setupPetProfile,
      stepLabel: l10n.onboardingStep(1, 3),
      progress: 0.33,
      onNext: widget.onNext,
      nextLabel: widget.nextLabel,
      onClose: widget.onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.petDetails, style: AppSemanticTextStyles.labelLBold),
          const SizedBox(height: AppSpacingTokens.md),
          LabeledTextField(
            label: l10n.petName,
            hintText: l10n.hintPetName,
            controller: _nameController,
            onChanged: widget.onNameChanged,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          BreedSearchField(
            label: l10n.breed,
            initialValue: widget.initialBreed,
            onChanged: widget.onBreedChanged,
            maxHeight: 160,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledTextField(
                  label: l10n.ageYears,
                  hintText: l10n.hintPetAge,
                  keyboardType: TextInputType.number,
                  controller: _ageController,
                  onChanged: widget.onAgeChanged,
                  prefixIcon: SvgPicture.asset(
                    AppAssets.onboardingCalendarIcon,
                    colorFilter: ColorFilter.mode(c.textTertiary, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm + 4),
              Expanded(
                child: LabeledTextField(
                  label: l10n.weightKg,
                  hintText: l10n.hintPetWeight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _weightController,
                  onChanged: widget.onWeightChanged,
                  prefixIcon: SvgPicture.asset(
                    AppAssets.onboardingPulseIcon,
                    colorFilter: ColorFilter.mode(c.textTertiary, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
