import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/onboarding/onboarding_flow.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step1.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('OnboardingFlow', () {
    testWidgets('renders step 1 on launch', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingFlow), findsOneWidget);
      // Step 1 should be visible — it uses OnboardingShell
      expect(find.byType(OnboardingShell), findsOneWidget);
    });

    testWidgets('shows pet name field on step 1', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      expect(find.text("Pet's Name"), findsOneWidget);
    });

    testWidgets('shows next button on step 1', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
    });
  });

  group('OnboardingFlow — step count', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingFlow), findsOneWidget);
    });

    testWidgets('shows step 1 first with OnboardingStep1 widget', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      // OnboardingStep1 should be visible on initial render
      expect(find.byType(OnboardingStep1), findsOneWidget);
    });

    testWidgets('step 1 shows "Step 1 of 3" (not "Step 1 of 4")', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsNothing);
    });

    testWidgets('PageView has exactly 3 children (not 4)', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      // The PageView inside OnboardingFlow should have 3 pages.
      final pageView = tester.widget<PageView>(find.byType(PageView));
      final delegate = pageView.childrenDelegate as SliverChildListDelegate;
      expect(delegate.children.length, 3);
    });
  });
}
