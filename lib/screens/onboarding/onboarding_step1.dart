import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
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
    this.onNameChanged,
    this.onBreedChanged,
    this.onAgeChanged,
    this.initialName,
    this.initialBreed,
    this.initialAge,
  });

  final VoidCallback? onNext;
  final String? nextLabel;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onBreedChanged;
  final ValueChanged<String>? onAgeChanged;
  final String? initialName;
  final String? initialBreed;
  final String? initialAge;

  @override
  State<OnboardingStep1> createState() => _OnboardingStep1State();
}

class _OnboardingStep1State extends State<OnboardingStep1>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _ageController.text = widget.initialAge ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    return OnboardingShell(
      title: l10n.setupPetProfile,
      stepLabel: l10n.onboardingStep(1, 3),
      progress: 0.33,
      onNext: widget.onNext,
      nextLabel: widget.nextLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tellUsAboutYourPet, style: AppSemanticTextStyles.headingLg),
          const SizedBox(height: AppSpacingTokens.md),
          LabeledTextField(
            label: l10n.petName,
            hintText: 'e.g., Max',
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
          LabeledTextField(
            label: l10n.ageYears,
            hintText: 'e.g., 8',
            keyboardType: TextInputType.number,
            controller: _ageController,
            onChanged: widget.onAgeChanged,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          LabeledTextField(
            label: l10n.photoUrl,
            hintText: 'https://...',
          ),
        ],
      ),
    );
  }
}
