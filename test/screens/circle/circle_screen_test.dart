import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/screens/circle/circle_screen.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_http_overrides.dart';

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  // ── Group 1: Renders without error ──────────────────────────────────────

  group('CircleScreen renders without error', () {
    testWidgets('renders with showScaffold=false', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircleScreen), findsOneWidget);
      // No Scaffold wrapper from CircleScreen itself — the testApp already
      // provides one, so there should be exactly one Scaffold in the tree.
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders with showScaffold=true', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: true)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircleScreen), findsOneWidget);
      // CircleScreen adds its own Scaffold + testApp adds one = 2 total.
      expect(find.byType(Scaffold), findsNWidgets(2));
    });
  });

  // ── Group 2: No active pet ─────────────────────────────────────────────

  group('CircleScreen with no active pet', () {
    testWidgets('shows empty state when petStore has no pets', (tester) async {
      suppressOverflowErrors();
      petStore.seed(ownerPets: [], clinicPets: []);

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('displays "No pets yet" text', (tester) async {
      suppressOverflowErrors();
      petStore.seed(ownerPets: [], clinicPets: []);

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('No pets yet'), findsOneWidget);
    });
  });

  // ── Group 3: With active pet ───────────────────────────────────────────

  group('CircleScreen with active pet', () {
    testWidgets('shows pet name in circle title', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // l10n circleTitle('Princess') => "Princess's Circle"
      expect(find.text("Princess's Circle"), findsOneWidget);
    });

    testWidgets('shows member count badge', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Princess has 3 care circle members (Hila, Dr. Smith, Sarah)
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('displays owner member with "Owner" role label',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Hila is the owner — her name and "Owner" label should appear.
      expect(find.text('Hila'), findsAtLeastNWidgets(1));
      // "Owner" appears both as the role text and inside the owner badge,
      // so we expect at least 2 occurrences.
      expect(find.text('Owner'), findsAtLeastNWidgets(2));
    });

    testWidgets('displays regular members with "Member" role label',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Smith'), findsOneWidget);
      expect(find.text('Sarah'), findsOneWidget);
      // Two non-owner members each have a "Member" role label.
      expect(find.text('Member'), findsNWidgets(2));
    });

    testWidgets('shows "Invite to Circle" button for owner', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // The owner sees the bottom "Invite to Circle" button.
      expect(find.text('Invite to Circle'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_alt_1), findsOneWidget);
    });
  });

  // ── Group 4: Empty circle (only owner) ─────────────────────────────────

  group('CircleScreen empty circle (only owner)', () {
    setUp(() {
      // Seed with a pet that has only the owner in its care circle.
      final ownerOnlyPet = Pet(
        name: 'Buddy',
        breedAndAge: 'Poodle - 3 years old',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(
          bpm: 20,
          recordedAt: DateTime.now(),
          recordedAtLabel: 'Just now',
        ),
        careCircle: const [
          CareCircleMember(
            name: 'Hila',
            avatarUrl: '',
            role: CareCircleRole.owner,
          ),
        ],
      );
      petStore.seed(ownerPets: [ownerOnlyPet], clinicPets: []);
    });

    testWidgets('shows invite description below owner tile', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // l10n circleEmptyDescription('Buddy') =>
      // "Invite family or caregivers to help monitor Buddy."
      expect(
        find.textContaining('Invite family or caregivers to help monitor Buddy'),
        findsOneWidget,
      );
    });

    testWidgets('shows invite button for owner', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // The owner always sees the bottom "Invite to Circle" button
      // with the person_add_alt_1 icon (not group_add from old empty state).
      expect(find.text('Invite to Circle'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_alt_1), findsOneWidget);
    });
  });

  // ── Group 5: Member tiles ──────────────────────────────────────────────

  group('CircleScreen member tiles', () {
    testWidgets('each member tile shows member name', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hila'), findsAtLeastNWidgets(1));
      expect(find.text('Dr. Smith'), findsOneWidget);
      expect(find.text('Sarah'), findsOneWidget);
    });

    testWidgets('each member tile shows role label', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Owner role label appears in the tile text and the badge.
      expect(find.text('Owner'), findsAtLeastNWidgets(2));
      // Two members with "Member" label.
      expect(find.text('Member'), findsNWidgets(2));
    });

    testWidgets('non-owner members show remove button when viewer is owner',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Two non-owner members should have close/remove icons.
      // The owner member tile should NOT have a close icon.
      expect(find.byIcon(Icons.close), findsNWidgets(2));
    });
  });

  // ── Group 6: Invite sheet ──────────────────────────────────────────────

  group('CircleScreen invite sheet', () {
    testWidgets('tapping "Invite to Circle" opens the bottom sheet',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      // The sheet opens a second instance of "Invite to Circle" as title.
      expect(find.text('Invite to Circle'), findsNWidgets(2));
    });

    testWidgets('bottom sheet contains email input field', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('email@example.com'), findsOneWidget);
    });

    testWidgets('bottom sheet contains "Send Invite" button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      expect(find.text('Send Invite'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('bottom sheet shows invite description with pet name',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      // l10n inviteDescription('Princess') contains the pet name.
      expect(
        find.textContaining("Princess's care circle"),
        findsOneWidget,
      );
    });
  });

  // ── Group 7: Invite sheet interactions ────────────────────────────────

  group('CircleScreen invite sheet interactions', () {
    testWidgets('entering text in email field shows typed text',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Open the invite sheet
      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      // Type an email
      await tester.enterText(find.byType(TextField), 'friend@example.com');
      await tester.pumpAndSettle();

      expect(find.text('friend@example.com'), findsOneWidget);
    });

    testWidgets('tapping "Send Invite" with empty email does nothing',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Open the invite sheet
      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      // Tap Send Invite without entering text
      await tester.tap(find.text('Send Invite'));
      await tester.pumpAndSettle();

      // The sheet should still show the email field — no success state
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Invite Sent!'), findsNothing);
    });

    testWidgets('email field has correct hint text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      // The hint text should be the placeholder email
      expect(find.text('email@example.com'), findsOneWidget);
    });

    testWidgets('can replace text in email field', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      // Enter first email
      await tester.enterText(find.byType(TextField), 'first@example.com');
      await tester.pumpAndSettle();
      expect(find.text('first@example.com'), findsOneWidget);

      // Replace with second email
      await tester.enterText(find.byType(TextField), 'second@example.com');
      await tester.pumpAndSettle();
      expect(find.text('second@example.com'), findsOneWidget);
      expect(find.text('first@example.com'), findsNothing);
    });

    testWidgets('sheet can be dismissed by dragging down', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Open the invite sheet
      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      // Verify sheet is open
      expect(find.text('Send Invite'), findsOneWidget);

      // Drag the sheet down to dismiss it
      await tester.drag(find.text('Send Invite'), const Offset(0, 500));
      await tester.pumpAndSettle();

      // Sheet should be dismissed — only the main button remains
      expect(find.text('Invite to Circle'), findsOneWidget);
    });
  });

  // ── Group 8: Pending invites section ─────────────────────────────────

  group('CircleScreen pending invites', () {
    setUp(() {
      // Seed with a pet that has pending invites.
      final petWithInvites = Pet(
        name: 'Luna',
        breedAndAge: 'Labrador - 5 years old',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(
          bpm: 22,
          recordedAt: DateTime.now(),
          recordedAtLabel: 'Just now',
        ),
        careCircle: const [
          CareCircleMember(
            name: 'Hila',
            avatarUrl: '',
            role: CareCircleRole.owner,
          ),
        ],
        pendingInvites: [
          PendingInvite(
            token: 'test-token-1',
            invitedEmail: 'friend@example.com',
            expiresAt: DateTime.now().add(const Duration(days: 5)),
          ),
          PendingInvite(
            token: 'test-token-2',
            invitedEmail: 'vet@clinic.com',
            expiresAt: DateTime.now().add(const Duration(days: 3)),
          ),
        ],
      );
      petStore.seed(ownerPets: [petWithInvites], clinicPets: []);
    });

    testWidgets('shows "Pending Invites" heading when invites exist',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pending Invites'), findsOneWidget);
    });

    testWidgets('shows pending invite email addresses', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('friend@example.com'), findsOneWidget);
      expect(find.text('vet@clinic.com'), findsOneWidget);
    });

    testWidgets('pending invite tiles show mail icon', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Each pending invite tile has a mail_outline icon
      expect(find.byIcon(Icons.mail_outline), findsNWidgets(2));
    });

    testWidgets('pending invites show cancel button for owner',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Each pending invite tile uses a TextButton with l10n.cancelInvite
      // which is "Cancel". There are 2 pending invites so 2 cancel buttons.
      // Find TextButtons whose child text is "Cancel" (from pending tiles).
      expect(
        find.widgetWithText(TextButton, 'Cancel'),
        findsNWidgets(2),
      );
    });

    testWidgets('does not show invite-empty description when invites exist',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // The empty description should not appear when there are pending invites
      expect(
        find.textContaining('Invite family or caregivers'),
        findsNothing,
      );
    });
  });

  // ── Group 9: Invite sheet mock-mode send ──────────────────────────────

  group('CircleScreen invite sheet send flow', () {
    testWidgets('invite sheet shows description text with pet name',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Open invite sheet
      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      // Verify the description mentions the pet name
      expect(
        find.textContaining("Princess's care circle"),
        findsOneWidget,
      );
    });

    testWidgets('email field is autofocused', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      // The TextField should have autofocus enabled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
    });

    testWidgets('send button has send icon', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite to Circle'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });

  // ── Group 10: Remove member dialog ────────────────────────────────────

  group('CircleScreen remove member dialog', () {
    testWidgets('tapping close on member opens confirmation dialog',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Tap the first close icon (non-owner member remove button)
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      // The confirmation dialog should appear
      expect(find.text('Remove Member'), findsOneWidget);
    });

    testWidgets('cancel in dialog dismisses without removing member',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(
        testApp(const CircleScreen(showScaffold: false)),
      );
      await tester.pumpAndSettle();

      // Tap the close icon for a member
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      // Tap Cancel in the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed, members still present
      expect(find.text('Dr. Smith'), findsOneWidget);
      expect(find.text('Sarah'), findsOneWidget);
    });
  });
}
