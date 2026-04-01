import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/invitation.dart';
import 'package:pet_circle/services/invitation_service.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
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
  String _petName = '';
  String _breedAndAge = '';
  String _age = '';
  String _diagnosis = '';
  int _targetRate = 30;
  bool _isSubmitting = false;
  final List<({String email, String role})> _careCircleInvites = [];
  final List<({String email, String? vetName})> _vetInvites = [];

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
        role: CareCircleRole.admin,
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

      if (kEnableFirebase && createdPet.id != null) {
        for (final inv in _careCircleInvites) {
          await InvitationService.createInvitation(
            petId: createdPet.id!,
            petName: petName,
            invitedEmail: inv.email,
            role: CareCirclePermissions.fromString(inv.role.toLowerCase()),
            invitedByUid: userStore.currentUserUid ?? '',
            invitedByName: userStore.currentUserDisplayName ?? '',
          );
        }
        for (final vet in _vetInvites) {
          await InvitationService.createInvitation(
            petId: createdPet.id!,
            petName: petName,
            invitedEmail: vet.email,
            role: CareCircleRole.viewer,
            invitedByUid: userStore.currentUserUid ?? '',
            invitedByName: userStore.currentUserDisplayName ?? '',
            type: InvitationType.vet,
          );
        }
      }

      // Mark onboarding as complete
      if (kEnableFirebase) {
        await UserService.updateOnboardingStatus(userStore.currentUserUid!, true);
        await authProvider.refresh();
      }

      if (!mounted) return;

      final role = userStore.role;
      context.go(AppRoutes.shell(role));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create pet: $e')),
      );
    }
  }

  void _goTo(int index) {
    if (index < 0 || index > 3) return;
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
          onNext: () => _goTo(3),
          nextLabel: l10n.next,
          onTargetRateChanged: (rate) => _targetRate = rate,
          initialTargetRate: _targetRate,
        ),
        OnboardingStep4(
          onBack: () => _goTo(2),
          onComplete: _onComplete,
          isSubmitting: _isSubmitting,
          onInviteAdded: (email, role) {
            _careCircleInvites.add((email: email, role: role));
          },
          onVetInvited: (email, vetName) {
            _vetInvites.add((email: email, vetName: vetName));
          },
        ),
      ],
    );
  }
}
