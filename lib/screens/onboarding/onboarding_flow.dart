import 'package:flutter/material.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step1.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step2.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step3.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step4.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  int _currentIndex = 0;
  String _petName = '';
  String _breedAndAge = '';
  String _age = '';
  String _diagnosis = '';
  int _targetRate = 30;
  List<String> _careCircleEmails = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onComplete() {
    final breedAge = _breedAndAge.isNotEmpty ? _breedAndAge : 'Unknown breed';
    final careCircleMembers = _careCircleEmails
        .where((e) => e.isNotEmpty)
        .map((email) => CareCircleMember(
              name: email,
              avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(email)}&background=E8B4B8&color=5B2C3F',
              role: CareCircleRole.member,
            ))
        .toList();
    petStore.addPet(Pet(
      name: _petName.isNotEmpty ? _petName : 'New Pet',
      breedAndAge: '$breedAge${_age.isNotEmpty ? " • $_age" : ""}',
      imageUrl: AppAssets.petPlaceholder,
      statusLabel: 'Normal',
      statusColorHex: AppColors.lightBlue.value,
      latestMeasurement: Measurement(bpm: 0, recordedAt: DateTime.now(), recordedAtLabel: 'No measurements yet'),
      careCircle: careCircleMembers,
      diagnosis: _diagnosis.isNotEmpty ? _diagnosis : null,
    ));
    settingsStore.updateThresholds(elevated: _targetRate);
    Navigator.of(context).pushReplacementNamed(AppRoutes.ownerDashboard);
  }

  void _goTo(int index) {
    if (index < 0 || index > 3) return;
    setState(() => _currentIndex = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) => setState(() => _currentIndex = index),
      children: [
        OnboardingStep1(
          onNext: () => _goTo(1),
          nextLabel: l10n.next,
          onNameChanged: (name) => _petName = name,
          onBreedChanged: (breed) => _breedAndAge = breed,
          onAgeChanged: (age) => _age = age,
          initialName: _petName,
          initialBreed: _breedAndAge,
          initialAge: _age,
        ),
        OnboardingStep2(
          onBack: () => _goTo(0),
          onNext: () => _goTo(2),
          nextLabel: l10n.next,
          onDiagnosisChanged: (diagnosis) => _diagnosis = diagnosis,
          initialDiagnosis: _diagnosis,
        ),
        OnboardingStep3(
          onBack: () => _goTo(1),
          onNext: () => _goTo(3),
          nextLabel: l10n.next,
          onTargetRateChanged: (rate) => _targetRate = rate,
          initialTargetRate: _targetRate,
        ),
        OnboardingStep4(
          onBack: () => _goTo(2),
          onComplete: _onComplete,
          onEmailAdded: (email) {
            _careCircleEmails = [..._careCircleEmails, email];
          },
        ),
      ],
    );
  }
}
