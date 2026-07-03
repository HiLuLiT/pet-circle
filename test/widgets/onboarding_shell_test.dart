import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

import '../helpers/test_app.dart';

void main() {
  group('OnboardingShell', () {
    Widget buildShell({
      String stepLabel = 'Step 1 of 4',
      double progress = 0.25,
      String title = 'Welcome',
      VoidCallback? onBack,
      VoidCallback? onNext,
      String? nextLabel,
      bool isNextLoading = false,
    }) {
      return testApp(
        OnboardingShell(
          stepLabel: stepLabel,
          progress: progress,
          title: title,
          onBack: onBack,
          onNext: onNext,
          nextLabel: nextLabel,
          isNextLoading: isNextLoading,
          child: const Text('Content'),
        ),
      );
    }

    // ── Smoke ─────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildShell());
      expect(find.byType(OnboardingShell), findsOneWidget);
    });

    // ── Title and step label ──────────────────────────────────────────────
    testWidgets('displays title text', (tester) async {
      await tester.pumpWidget(buildShell(title: 'Add your pet'));
      expect(find.text('Add your pet'), findsOneWidget);
    });

    testWidgets('does not display step label (dropped per current DS spec)',
        (tester) async {
      await tester.pumpWidget(buildShell(stepLabel: 'Step 2 of 4'));
      expect(find.text('Step 2 of 4'), findsNothing);
    });

    testWidgets('displays child content', (tester) async {
      await tester.pumpWidget(buildShell());
      expect(find.text('Content'), findsOneWidget);
    });

    // ── Buttons ───────────────────────────────────────────────────────────
    testWidgets('shows next button with custom label', (tester) async {
      await tester.pumpWidget(buildShell(
        onNext: () {},
        nextLabel: 'Continue',
      ));
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('shows back button when onBack is provided', (tester) async {
      await tester.pumpWidget(buildShell(onBack: () {}));
      // Back is now an icon-only RoundIconButton (no text label).
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('hides back button when onBack is null', (tester) async {
      await tester.pumpWidget(buildShell());
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('shows loading spinner when isNextLoading is true',
        (tester) async {
      await tester.pumpWidget(buildShell(
        onNext: () {},
        isNextLoading: true,
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ── Interaction ───────────────────────────────────────────────────────
    testWidgets('tapping next calls onNext', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildShell(
        onNext: () => tapped = true,
        nextLabel: 'Next',
      ));

      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('tapping back calls onBack', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildShell(
        onBack: () => tapped = true,
        onNext: () {},
      ));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      expect(tapped, isTrue);
    });

    // ── Theme token verification ──────────────────────────────────────────
    testWidgets('title uses pcDisplay style (Display/M, DS spec)',
        (tester) async {
      await tester.pumpWidget(buildShell(title: 'Setup'));

      final titleWidget = tester.widget<Text>(find.text('Setup'));
      expect(titleWidget.style?.fontSize, AppSemanticTextStyles.pcDisplay.fontSize);
      expect(titleWidget.style?.fontWeight,
          AppSemanticTextStyles.pcDisplay.fontWeight);
    });

    testWidgets('progress bar uses surface (white) bg and primary foreground',
        (tester) async {
      await tester.pumpWidget(buildShell(progress: 0.5));

      // Find the Container widgets used for the progress bar
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();

      // The progress bar background should use surface (white) color per the
      // DS spec (Figma node 402:1861 shows bg-white for the track).
      final bgContainer = containers.where((c) {
        return c.color == AppSemanticColors.light.surface;
      });
      expect(bgContainer.isNotEmpty, isTrue,
          reason: 'Progress bar bg should use surface color');

      // The progress bar foreground should use primary color
      final fgContainer = containers.where((c) {
        return c.color == AppSemanticColors.light.primary;
      });
      expect(fgContainer.isNotEmpty, isTrue,
          reason: 'Progress bar fg should use primary color');
    });
  });
}
