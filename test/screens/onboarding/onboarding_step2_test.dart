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

    testWidgets('does not show a "Step X of Y" label (dropped per DS spec)',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsNothing);
    });

    testWidgets('shows diagnosis text field with placeholder hint', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      // DS alignment: the diagnosis dropdown was replaced with a free-text
      // TextField; its hint text is l10n.diagnosisHint.
      expect(
        find.text('e.g. Moderate Degenerative Mitral Valve Disease'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows "Diagnosis" label with "(optional)" suffix', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      // DS alignment: "Diagnosis (Optional)" is now two separate Text
      // widgets — l10n.diagnosisLabel ("Diagnosis") and l10n.optionalSuffix
      // ("(optional)").
      expect(find.text('Diagnosis'), findsOneWidget);
      expect(find.text('(optional)'), findsOneWidget);
    });

    testWidgets('shows "Medical information" heading', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      // l10n copy consolidation: heading casing changed to sentence case.
      expect(find.text('Medical information'), findsOneWidget);
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

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
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

      await tester.tap(find.byIcon(Icons.arrow_back));
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

    testWidgets('typing in the diagnosis field calls onDiagnosisChanged',
        (tester) async {
      suppressOverflowErrors();

      String? selectedDiagnosis;
      await tester.pumpWidget(testApp(
        OnboardingStep2(
          onDiagnosisChanged: (d) => selectedDiagnosis = d,
        ),
      ));
      await tester.pumpAndSettle();

      // DS alignment: diagnosis is now free text, not a dropdown selection.
      await tester.enterText(find.byType(TextField), 'Heart murmur');
      await tester.pumpAndSettle();

      expect(selectedDiagnosis, 'Heart murmur');
    });

    testWidgets('typing in the diagnosis field updates the displayed text',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        OnboardingStep2(
          onDiagnosisChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Heart murmur');
      await tester.pumpAndSettle();

      // The TextField now shows the entered value.
      expect(find.text('Heart murmur'), findsOneWidget);
    });

    testWidgets('shows note section about diagnosis data', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(),
      ));
      await tester.pumpAndSettle();

      // l10n copy consolidation: NoteCallout title is now "Note" (no colon).
      expect(find.text('Note'), findsOneWidget);
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

    testWidgets('initialDiagnosis pre-fills the text field', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep2(
          initialDiagnosis: 'Diagnosis 03',
        ),
      ));
      await tester.pumpAndSettle();

      // DS alignment: the diagnosis field is free text now, so the initial
      // value pre-fills the TextField's controller.
      expect(find.text('Diagnosis 03'), findsOneWidget);
    });
  });
}
