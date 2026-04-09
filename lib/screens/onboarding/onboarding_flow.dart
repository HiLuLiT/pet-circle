import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step1.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step2.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step3.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  String _petName = '';
  String _breedAndAge = '';
  String _age = '';
  String _diagnosis = '';
  int _targetRate = 30;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onComplete() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final breedAge = _breedAndAge.isNotEmpty ? _breedAndAge : 'Unknown breed';

      final ownerMember = CareCircleMember(
        uid: userStore.currentUserUid,
        name: userStore.currentUserDisplayName ?? '',
        avatarUrl: userStore.currentUserAvatarUrl ??
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userStore.currentUserDisplayName ?? '')}&background=E8B4B8&color=5B2C3F',
        role: CareCircleRole.owner,
      );

      final petName = _petName.isNotEmpty ? _petName : 'New Pet';
      final pet = Pet(
        name: petName,
        breedAndAge: '$breedAge${_age.isNotEmpty ? " • $_age" : ""}',
        imageUrl: AppAssets.petPlaceholder,
        statusLabel: 'Normal',
        statusColorHex: AppPrimitives.blueLight.toARGB32(),
        latestMeasurement: Measurement(bpm: 0, recordedAt: DateTime.now(), recordedAtLabel: 'No measurements yet'),
        careCircle: [ownerMember],
        diagnosis: _diagnosis.isNotEmpty ? _diagnosis : null,
        ownerId: kEnableFirebase ? userStore.currentUserUid : null,
      );

      final createdPet = await petStore.createPetWithFirestore(pet);
      await settingsStore.updateThresholds(elevated: _targetRate);

      // Mark onboarding as complete
      if (kEnableFirebase) {
        await userStore.updateOnboardingStatus(userStore.currentUserUid!, true);
        await authProvider.refresh();
      }

      if (!mounted) return;

      context.go(AppRoutes.shell());
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create pet: $e')),
      );
    }
  }

  void _goTo(int index) {
    if (index < 0 || index > 2) return;
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
          onNext: _onComplete,
          nextLabel: l10n.complete,
          onTargetRateChanged: (rate) => _targetRate = rate,
          initialTargetRate: _targetRate,
          isNextLoading: _isSubmitting,
        ),
      ],
    );
  }
}
