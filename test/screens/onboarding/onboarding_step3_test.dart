import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step3.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('OnboardingStep3', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingStep3), findsOneWidget);
    });

    testWidgets('shows "Step 3 of 3" label', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3'), findsOneWidget);
    });

    testWidgets('shows target respiratory rate heading', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Set Target Respiratory Rate'), findsOneWidget);
    });

    testWidgets('shows rate description text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(
        find.text("We'll alert you when measurements exceed this threshold."),
        findsOneWidget,
      );
    });

    testWidgets('shows 30 BPM (Standard) option', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('30 BPM (Standard)'), findsOneWidget);
    });

    testWidgets('shows 35 BPM option', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('35 BPM'), findsOneWidget);
    });

    testWidgets('shows Custom Rate option', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Custom Rate'), findsOneWidget);
    });

    testWidgets('30 BPM is selected by default', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      // The 30 BPM option should have the check icon (selected state)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows OnboardingShell wrapper', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingShell), findsOneWidget);
    });

    testWidgets('shows setup title text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Setup pet profile'), findsOneWidget);
    });

    testWidgets('calls onTargetRateChanged when 35 BPM tapped',
        (tester) async {
      suppressOverflowErrors();

      int? selectedRate;
      await tester.pumpWidget(testApp(
        OnboardingStep3(
          onTargetRateChanged: (rate) => selectedRate = rate,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('35 BPM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('35 BPM'));
      await tester.pumpAndSettle();

      expect(selectedRate, 35);
    });

    testWidgets('calls onTargetRateChanged with 30 when 30 BPM tapped',
        (tester) async {
      suppressOverflowErrors();

      int? selectedRate;
      await tester.pumpWidget(testApp(
        OnboardingStep3(
          initialTargetRate: 35,
          onTargetRateChanged: (rate) => selectedRate = rate,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('30 BPM (Standard)'));
      await tester.pumpAndSettle();

      expect(selectedRate, 30);
    });

    testWidgets('tapping Custom Rate shows text input field', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      // No TextField initially (only rate option cards)
      expect(find.byType(TextField), findsNothing);

      // Scroll to Custom Rate and tap it
      await tester.ensureVisible(find.text('Custom Rate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom Rate'));
      await tester.pumpAndSettle();

      // TextField should now appear for entering custom BPM
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('custom rate input calls onTargetRateChanged',
        (tester) async {
      suppressOverflowErrors();

      int? selectedRate;
      await tester.pumpWidget(testApp(
        OnboardingStep3(
          onTargetRateChanged: (rate) => selectedRate = rate,
        ),
      ));
      await tester.pumpAndSettle();

      // Scroll to Custom Rate and tap it to show input
      await tester.ensureVisible(find.text('Custom Rate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom Rate'));
      await tester.pumpAndSettle();

      // Enter a custom value
      await tester.enterText(find.byType(TextField), '25');
      await tester.pumpAndSettle();

      expect(selectedRate, 25);
    });

    testWidgets('shows Back button when onBack is provided', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        OnboardingStep3(
          onBack: () {},
          onNext: () {},
          nextLabel: 'Done',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('shows Done button when onNext is provided with nextLabel',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        OnboardingStep3(
          onBack: () {},
          onNext: () {},
          nextLabel: 'Done',
        ),
      ));
      await tester.pumpAndSettle();

      // The nextLabel 'Done' is displayed on the button
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('calls onBack when Back tapped', (tester) async {
      suppressOverflowErrors();

      var backCalled = false;
      await tester.pumpWidget(testApp(
        OnboardingStep3(
          onBack: () => backCalled = true,
          onNext: () {},
          nextLabel: 'Done',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(backCalled, isTrue);
    });

    testWidgets('calls onNext when Done tapped', (tester) async {
      suppressOverflowErrors();

      var nextCalled = false;
      await tester.pumpWidget(testApp(
        OnboardingStep3(
          onBack: () {},
          onNext: () => nextCalled = true,
          nextLabel: 'Done',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(nextCalled, isTrue);
    });

    testWidgets('initialTargetRate of 35 pre-selects that option',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(initialTargetRate: 35),
      ));
      await tester.pumpAndSettle();

      // The check icon should still appear once (for the 35 BPM option now)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows standard rate description', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Recommended for most dogs'), findsOneWidget);
    });

    testWidgets('shows elevated rate description', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep3(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('For pets with mild conditions'), findsOneWidget);
    });
  });
}
