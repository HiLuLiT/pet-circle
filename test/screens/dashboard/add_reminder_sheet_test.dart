import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/reminder.dart';
import 'package:pet_circle/screens/dashboard/add_reminder_sheet.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/reminder_store.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/test_http_overrides.dart';
void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());

  setUp(seedAllStores);
  tearDown(resetAllStores);

  Future<void> setSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(480, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('AddReminderSheet — add mode', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      await tester.pumpWidget(testApp(const AddReminderSheet()));
      await tester.pumpAndSettle();

      expect(find.byType(AddReminderSheet), findsOneWidget);
    });

    testWidgets('shows add new reminder title', (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      await tester.pumpWidget(testApp(const AddReminderSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Add new reminder'), findsOneWidget);
    });

    testWidgets('renders title, date, and detail fields', (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      await tester.pumpWidget(testApp(const AddReminderSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('does not show a delete icon in add mode', (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      await tester.pumpWidget(testApp(const AddReminderSheet()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('tapping save with empty title shows a validation error '
        'and does not call the store', (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      final petId = petStore.activePet!.id!;
      final before = reminderStore.getReminders(petId).length;

      await tester.pumpWidget(testApp(const AddReminderSheet()));
      await tester.pumpAndSettle();

      // Neither Title nor Date is filled — Form.validate() fails before
      // reminderStore.addReminder is ever called, so no Firestore call is
      // attempted and this tap is safe to await directly.
      await tester.tap(find.text('Add reminder'));
      await tester.pumpAndSettle();

      expect(find.text('This field is required'), findsWidgets);
      expect(reminderStore.getReminders(petId).length, before);
      // Sheet is still present — save was rejected by validation.
      expect(find.byType(AddReminderSheet), findsOneWidget);
    });

    testWidgets(
        'when Firestore write fails, sheet stays open and error snackbar shown',
        (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      final petId = petStore.activePet!.id!;
      final before = reminderStore.getReminders(petId).length;

      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const AddReminderSheet(),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AddReminderSheet), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Grooming');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextFormField).at(1));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // _save() now awaits the store call and catches errors. In this
      // test environment (no Firebase.initializeApp()), the Firestore
      // write throws, _save catches it, and shows an error snackbar.
      await tester.tap(find.text('Add reminder'));
      await tester.pumpAndSettle();

      // Sheet stays open — the save failed, so the user can retry.
      expect(find.byType(AddReminderSheet), findsOneWidget);
      // Reminder count unchanged (store rolled back the optimistic insert).
      expect(reminderStore.getReminders(petId).length, before);
      expect(
        reminderStore.getReminders(petId).any((r) => r.title == 'Grooming'),
        isFalse,
      );
      // Error snackbar is shown.
      expect(
        find.text("Couldn't save the reminder. Please try again."),
        findsOneWidget,
      );
    });
  });

  group('AddReminderSheet — edit mode', () {
    Reminder existingReminder() {
      final petId = petStore.activePet!.id!;
      return reminderStore.getReminders(petId).first;
    }

    testWidgets('shows edit reminder title', (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      final reminder = existingReminder();
      await tester.pumpWidget(testApp(AddReminderSheet(reminder: reminder)));
      await tester.pumpAndSettle();

      expect(find.text('Edit reminder'), findsOneWidget);
    });

    testWidgets('pre-fills fields with the reminder values', (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      final reminder = existingReminder();
      await tester.pumpWidget(testApp(AddReminderSheet(reminder: reminder)));
      await tester.pumpAndSettle();

      expect(find.text(reminder.title), findsOneWidget);
      if (reminder.detail != null && reminder.detail!.isNotEmpty) {
        expect(find.text(reminder.detail!), findsOneWidget);
      }
    });

    testWidgets('shows a delete icon in edit mode', (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      final reminder = existingReminder();
      await tester.pumpWidget(testApp(AddReminderSheet(reminder: reminder)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets(
        'when Firestore delete fails, sheet stays open and error snackbar shown',
        (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      final petId = petStore.activePet!.id!;
      final reminder = existingReminder();
      final before = reminderStore.getReminders(petId).length;

      await tester
          .pumpWidget(testApp(AddReminderSheet(reminder: reminder)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete reminder'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // _confirmDelete now catches the Firestore error, shows an error
      // snackbar, and keeps the sheet open.
      expect(reminderStore.getReminders(petId).length, before);
      expect(find.byType(AddReminderSheet), findsOneWidget);
      expect(
        find.text("Couldn't delete the reminder. Please try again."),
        findsOneWidget,
      );
    });

    testWidgets('tapping delete then cancelling keeps the reminder',
        (tester) async {
      suppressOverflowErrors();
      await setSize(tester);

      final petId = petStore.activePet!.id!;
      final reminder = existingReminder();
      final before = reminderStore.getReminders(petId).length;

      await tester.pumpWidget(testApp(AddReminderSheet(reminder: reminder)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      // The sheet's own "Cancel" outlined button also has this text, so
      // scope the finder to the dialog's action.
      await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel'),
      ));
      await tester.pumpAndSettle();

      expect(reminderStore.getReminders(petId).length, before);
      expect(find.byType(AddReminderSheet), findsOneWidget);
    });
  });
}
