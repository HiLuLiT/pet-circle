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

    testWidgets('displays step label', (tester) async {
      await tester.pumpWidget(buildShell(stepLabel: 'Step 2 of 4'));
      expect(find.text('Step 2 of 4'), findsOneWidget);
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
      // "Back" is the localised label
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('hides back button when onBack is null', (tester) async {
      await tester.pumpWidget(buildShell());
      expect(find.text('Back'), findsNothing);
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

      await tester.tap(find.text('Back'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    // ── Theme token verification ──────────────────────────────────────────
    testWidgets('title uses title2 style', (tester) async {
      await tester.pumpWidget(buildShell(title: 'Setup'));

      final titleWidget = tester.widget<Text>(find.text('Setup'));
      expect(titleWidget.style?.fontSize, AppSemanticTextStyles.title2.fontSize);
      expect(
          titleWidget.style?.fontWeight, AppSemanticTextStyles.title2.fontWeight);
    });

    testWidgets('step label uses caption style with secondary color',
        (tester) async {
      await tester.pumpWidget(buildShell(stepLabel: 'Step 3 of 4'));

      final label = tester.widget<Text>(find.text('Step 3 of 4'));
      expect(label.style?.fontSize, AppSemanticTextStyles.caption.fontSize);
      expect(label.style?.color, AppSemanticColors.light.textSecondary);
    });

    testWidgets('progress bar uses divider bg and primary foreground',
        (tester) async {
      await tester.pumpWidget(buildShell(progress: 0.5));

      // Find the Container widgets used for the progress bar
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();

      // The progress bar background should use divider color
      final bgContainer = containers.where((c) {
        return c.color == AppSemanticColors.light.divider;
      });
      expect(bgContainer.isNotEmpty, isTrue,
          reason: 'Progress bar bg should use divider color');

      // The progress bar foreground should use primary color
      final fgContainer = containers.where((c) {
        return c.color == AppSemanticColors.light.primary;
      });
      expect(fgContainer.isNotEmpty, isTrue,
          reason: 'Progress bar fg should use primary color');
    });
  });
}
