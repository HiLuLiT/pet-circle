import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step4.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('OnboardingStep4', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingStep4), findsOneWidget);
    });

    testWidgets('shows OnboardingShell wrapper', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingShell), findsOneWidget);
    });

    testWidgets('shows "Setup pet profile" title', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.text('Setup pet profile'), findsOneWidget);
    });

    testWidgets('shows "Step 4 of 4" step label', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.text('Step 4 of 4'), findsOneWidget);
    });

    testWidgets('shows "Invite Your Veterinarian" section heading',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.text('Invite Your Veterinarian'), findsOneWidget);
    });

    testWidgets('shows vet section description text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(
        find.text('Look up your vet by email to connect them to this pet.'),
        findsOneWidget,
      );
    });

    testWidgets('shows "Invite Your Care Circle" section heading',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.text('Invite Your Care Circle'), findsOneWidget);
    });

    testWidgets('shows care circle description text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Invite family members, pet sitters, and veterinarians to collaborate.'),
        findsOneWidget,
      );
    });

    testWidgets('shows "Look Up" button for vet email lookup', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.text('Look Up'), findsOneWidget);
    });

    testWidgets('shows "Add to pet circle" button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.text('Add to pet circle'), findsOneWidget);
    });

    testWidgets('shows "Complete" button when onComplete is provided',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        OnboardingStep4(onComplete: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Complete'), findsOneWidget);
    });

    testWidgets('shows "Email address" label in vet section', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      // Both vet and care circle sections have "Email address" labels.
      expect(find.text('Email address'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows "Role" label for care circle invite', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.text('Role'), findsOneWidget);
    });

    testWidgets('shows default role "Member" in select row', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.text('Member'), findsOneWidget);
    });

    testWidgets('shows Back button when onBack is provided', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        OnboardingStep4(onBack: () {}, onComplete: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('calls onBack when Back button is tapped', (tester) async {
      suppressOverflowErrors();

      var backCalled = false;
      await tester.pumpWidget(testApp(
        OnboardingStep4(
          onBack: () => backCalled = true,
          onComplete: () {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(backCalled, isTrue);
    });

    testWidgets('calls onComplete when Complete button is tapped',
        (tester) async {
      suppressOverflowErrors();

      var completeCalled = false;
      await tester.pumpWidget(testApp(
        OnboardingStep4(
          onBack: () {},
          onComplete: () => completeCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      expect(completeCalled, isTrue);
    });

    testWidgets('tapping role dropdown opens role options', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      // The role selector may be off-screen — scroll to it first
      await tester.ensureVisible(find.text('Member'));
      await tester.pumpAndSettle();

      // Tap the select row (shows the current "Member" value)
      await tester.tap(find.text('Member'));
      await tester.pumpAndSettle();

      // All three role options should appear in the dropdown list
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Viewer'), findsOneWidget);
    });

    testWidgets('selecting a role from the dropdown updates the display',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      // Scroll to the role selector
      await tester.ensureVisible(find.text('Member'));
      await tester.pumpAndSettle();

      // Open the dropdown
      await tester.tap(find.text('Member'));
      await tester.pumpAndSettle();

      // Ensure Admin option is visible and tap it
      await tester.ensureVisible(find.text('Admin'));
      await tester.pumpAndSettle();

      // Select "Admin"
      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();

      // "Admin" should now be displayed as the selected value
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets(
        'entering empty email and tapping "Add to pet circle" shows error snackbar',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      // Scroll to the button before tapping
      await tester.ensureVisible(find.text('Add to pet circle'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to pet circle'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an email address'), findsOneWidget);
    });

    testWidgets(
        'entering a valid email and tapping "Add to pet circle" calls onInviteAdded',
        (tester) async {
      suppressOverflowErrors();

      String? capturedEmail;
      String? capturedRole;
      await tester.pumpWidget(testApp(
        OnboardingStep4(
          onInviteAdded: (email, role) {
            capturedEmail = email;
            capturedRole = role;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Scroll to the care circle email field (last TextField in the scrollable)
      final emailFields = find.byType(TextField);
      await tester.ensureVisible(emailFields.last);
      await tester.pumpAndSettle();

      await tester.enterText(emailFields.last, 'friend@example.com');
      await tester.pumpAndSettle();

      // Scroll to and tap the Add to care circle button
      await tester.ensureVisible(find.text('Add to pet circle'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to pet circle'));
      await tester.pumpAndSettle();

      expect(capturedEmail, 'friend@example.com');
      expect(capturedRole, 'Member');
    });

    testWidgets(
        'entering email and adding to care circle shows invite in list',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      final emailFields = find.byType(TextField);
      await tester.ensureVisible(emailFields.last);
      await tester.pumpAndSettle();

      await tester.enterText(emailFields.last, 'team@example.com');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add to pet circle'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to pet circle'));
      await tester.pumpAndSettle();

      // The invited email should now appear in the invite list
      expect(find.text('team@example.com'), findsAtLeastNWidgets(1));
    });

    testWidgets(
        'vet lookup in mock mode shows "no account found" message',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      // Enter a vet email and tap Look Up (kEnableFirebase=false → notFound)
      final vetEmailField = find.byType(TextField).first;
      await tester.enterText(vetEmailField, 'vet@clinic.com');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Look Up'));
      await tester.pumpAndSettle();

      // In mock mode, _VetLookupState.notFound is set, showing the invite button
      expect(find.text('Send Vet Invite'), findsOneWidget);
    });

    testWidgets('shows local_hospital icon in vet section heading',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_hospital), findsOneWidget);
    });

    testWidgets('shows person_add_alt_1 icon in Add to care circle button',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const OnboardingStep4()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_add_alt_1), findsOneWidget);
    });

    testWidgets('isSubmitting=true shows loading indicator on Complete button',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(
        const OnboardingStep4(isSubmitting: true),
      ));
      // Use pump with a duration instead of pumpAndSettle to avoid
      // timing out on the continuously-animating CircularProgressIndicator.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });
  });
}
