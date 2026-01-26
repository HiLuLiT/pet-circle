import 'package:flutter/material.dart';
import 'package:pet_circle/app_routes.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return PageView(
      controller: _controller,
      physics: const PageScrollPhysics(),
      onPageChanged: (index) => setState(() => _currentIndex = index),
      children: [
        OnboardingStep1(onNext: () => _goTo(1)),
        OnboardingStep2(onBack: () => _goTo(0), onNext: () => _goTo(2)),
        OnboardingStep3(onBack: () => _goTo(1), onNext: () => _goTo(3)),
        OnboardingStep4(
          onBack: () => _goTo(2),
          onComplete: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.ownerDashboard),
        ),
      ],
    );
  }
}
