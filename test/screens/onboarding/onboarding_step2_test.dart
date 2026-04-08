import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step2.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('OnboardingStep2', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingStep2), findsOneWidget);
    });

    testWidgets('shows "Step 2 of 3" label', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);
    });

    testWidgets('shows diagnosis dropdown trigger', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      // The dropdown trigger shows "Select diagnosis" as placeholder
      expect(find.text('Select diagnosis'), findsOneWidget);
    });

    testWidgets('shows "Diagnosis (Optional)" label', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Diagnosis (Optional)'), findsOneWidget);
    });

    testWidgets('shows "Medical Information" heading', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Medical Information'), findsOneWidget);
    });

    testWidgets('shows Back button when onBack is provided', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        OnboardingStep2(
          onBack: () {},
          onNext: () {},
          nextLabel: 'Next',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('shows Next button when onNext is provided', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        OnboardingStep2(
          onBack: () {},
          onNext: () {},
          nextLabel: 'Next',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('calls onBack when Back button tapped', (tester) async {
      suppressOverflowErrors();

      var backCalled = false;
      await tester.pumpWidget(testApp(
        OnboardingStep2(
          onBack: () => backCalled = true,
          onNext: () {},
          nextLabel: 'Next',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(backCalled, isTrue);
    });

    testWidgets('calls onNext when Next button tapped', (tester) async {
      suppressOverflowErrors();

      var nextCalled = false;
      await tester.pumpWidget(testApp(
        OnboardingStep2(
          onBack: () {},
          onNext: () => nextCalled = true,
          nextLabel: 'Next',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(nextCalled, isTrue);
    });

    testWidgets('tapping dropdown trigger opens diagnosis list',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      // Tap the dropdown trigger (contains "Select diagnosis" text)
      await tester.tap(find.text('Select diagnosis'));
      await tester.pumpAndSettle();

      // Diagnosis options should now be visible
      expect(find.text('Diagnosis 01'), findsOneWidget);
      expect(find.text('Diagnosis 02'), findsOneWidget);
      expect(find.text('Diagnosis 03'), findsOneWidget);
    });

    testWidgets('selecting a diagnosis calls onDiagnosisChanged',
        (tester) async {
      suppressOverflowErrors();

      String? selectedDiagnosis;
      await tester.pumpWidget(testApp(
        OnboardingStep2(
          onDiagnosisChanged: (d) => selectedDiagnosis = d,
        ),
      ));
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.text('Select diagnosis'));
      await tester.pumpAndSettle();

      // Select "Diagnosis 01"
      await tester.tap(find.text('Diagnosis 01'));
      await tester.pumpAndSettle();

      expect(selectedDiagnosis, 'Diagnosis 01');
    });

    testWidgets('selecting a diagnosis updates the displayed text',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        OnboardingStep2(
          onDiagnosisChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.text('Select diagnosis'));
      await tester.pumpAndSettle();

      // Scroll to make the diagnosis option visible, then tap it
      await tester.ensureVisible(find.text('Diagnosis 01'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Diagnosis 01'));
      await tester.pumpAndSettle();

      // The dropdown trigger should now show the selected diagnosis
      expect(find.text('Diagnosis 01'), findsOneWidget);
      // "Select diagnosis" placeholder should be gone
      expect(find.text('Select diagnosis'), findsNothing);
    });

    testWidgets('shows note section about diagnosis data', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Note:'), findsOneWidget);
    });

    testWidgets('shows OnboardingShell wrapper', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingShell), findsOneWidget);
    });

    testWidgets('shows setup title text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Setup pet profile'), findsOneWidget);
    });

    testWidgets('initialDiagnosis pre-selects dropdown value', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(
          initialDiagnosis: 'Diagnosis 03',
        ),
      ));
      await tester.pumpAndSettle();

      // The pre-selected diagnosis should appear instead of placeholder
      expect(find.text('Diagnosis 03'), findsOneWidget);
      expect(find.text('Select diagnosis'), findsNothing);
    });
  });
}
