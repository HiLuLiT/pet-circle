import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/screens/medication/add_medication_sheet.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/widgets/app_toggle.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/reminder_time_row.dart';

import '../../helpers/fake_local_notifications.dart';
import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  _remindersTests();
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('AddMedicationSheet', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.byType(AddMedicationSheet), findsOneWidget);
    });

    testWidgets('shows add new medication title when creating', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Add New Medication'), findsOneWidget);
    });

    testWidgets('shows required form fields', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      // Required fields
      expect(find.text('Medication Name *'), findsOneWidget);
      expect(find.text('Dosage *'), findsOneWidget);
      expect(find.text('Frequency *'), findsOneWidget);
      expect(find.text('Start Date *'), findsOneWidget);
    });

    testWidgets('shows optional form fields', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Additional Notes'), findsOneWidget);
    });

    testWidgets('does not show fields outside the Figma spec (Prescribed By, '
        'Purpose/Condition, Reminders)', (tester) async {
      // DS alignment (Figma node 402-2388): these fields aren't part of the
      // "Add medication" drawer design and were removed from the form.
      // Existing records keep whatever values they already had (preserved
      // via copyWith on save) — this only removes the ability to set them.
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Prescribed By'), findsNothing);
      expect(find.text('Purpose / Condition'), findsNothing);
      expect(find.text('Medication Reminders'), findsNothing);
    });

    testWidgets('shows cancel and add medication buttons', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const AddMedicationSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add Medication'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Per-medication dose reminders
// ---------------------------------------------------------------------------

Medication _seedMedication({
  String frequency = 'Once daily',
  bool remindersEnabled = false,
  List<String> reminderTimes = const [],
}) {
  final petId = petStore.ownerPets.first.id!;
  final med = Medication(
    id: 'med-reminders',
    petId: petId,
    name: 'Furosemide',
    dosage: '10mg',
    frequency: frequency,
    startDate: DateTime(2026, 1, 1),
    remindersEnabled: remindersEnabled,
    reminderTimes: reminderTimes,
  );
  medicationStore.seed({
    petId: [med],
  });
  return med;
}

Medication _savedMedication() =>
    medicationStore.getMedications(petStore.ownerPets.first.id!).single;

Future<void> _pumpSheet(WidgetTester tester, Medication med) async {
  tester.view.physicalSize = const Size(480, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(testApp(AddMedicationSheet(medication: med)));
  await tester.pumpAndSettle();
}

Future<void> _selectFrequency(WidgetTester tester, String label) async {
  await tester.tap(find.text('Frequency *'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(PrimaryButton, 'Save'));
  await tester.pumpAndSettle();
}

void _remindersTests() {
  group('AddMedicationSheet reminders', () {
    setUp(() {
      seedAllStores();
      // Blank the uid so the store's Firestore write path is skipped —
      // these tests exercise the in-memory result of _save() only.
      userStore.seed(MockData.currentOwnerUser.copyWith(id: ''));
      // flutter_local_notifications has no implementation under flutter_test;
      // install a no-op platform so the fire-and-forget scheduling and
      // cancelling calls in _save() are harmless.
      installFakeLocalNotifications();
    });

    tearDown(resetAllStores);

    testWidgets('toggle off saves no reminder times', (tester) async {
      await _pumpSheet(tester, _seedMedication(frequency: 'Twice daily'));
      await _save(tester);

      final saved = _savedMedication();
      expect(saved.remindersEnabled, isFalse);
      expect(saved.reminderTimes, isEmpty);
    });

    testWidgets('Once daily with reminders on saves one time', (tester) async {
      await _pumpSheet(tester, _seedMedication(frequency: 'Once daily'));

      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();
      await _save(tester);

      final saved = _savedMedication();
      expect(saved.remindersEnabled, isTrue);
      expect(saved.reminderTimes, ['09:00']);
    });

    testWidgets('Twice daily with reminders on saves two times', (
      tester,
    ) async {
      await _pumpSheet(tester, _seedMedication(frequency: 'Twice daily'));

      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();
      await _save(tester);

      final saved = _savedMedication();
      expect(saved.remindersEnabled, isTrue);
      expect(saved.reminderTimes, ['09:00', '21:00']);
    });

    testWidgets('As needed with reminders on saves no dose times', (
      tester,
    ) async {
      await _pumpSheet(tester, _seedMedication(frequency: 'As needed'));

      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();
      await _save(tester);

      final saved = _savedMedication();
      expect(saved.remindersEnabled, isTrue);
      expect(saved.reminderTimes, isEmpty);
    });

    testWidgets('shows one dose row for Once daily, two for Twice daily', (
      tester,
    ) async {
      await _pumpSheet(tester, _seedMedication(frequency: 'Once daily'));

      expect(find.byType(ReminderTimeRow), findsNothing);

      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();
      expect(find.byType(ReminderTimeRow), findsOneWidget);
      expect(find.text('Reminder time'), findsOneWidget);

      await _selectFrequency(tester, 'Twice daily');
      expect(find.byType(ReminderTimeRow), findsNWidgets(2));
      expect(find.text('First dose'), findsOneWidget);
      expect(find.text('Second dose'), findsOneWidget);

      await _selectFrequency(tester, 'As needed');
      expect(find.byType(ReminderTimeRow), findsNothing);
    });

    testWidgets('Twice -> Once keeps the first chosen time', (tester) async {
      await _pumpSheet(
        tester,
        _seedMedication(
          frequency: 'Twice daily',
          remindersEnabled: true,
          reminderTimes: const ['07:30', '19:30'],
        ),
      );

      await _selectFrequency(tester, 'Once daily');
      await _save(tester);

      expect(_savedMedication().reminderTimes, ['07:30']);
    });

    testWidgets('seeds the toggle and times from the edited medication', (
      tester,
    ) async {
      await _pumpSheet(
        tester,
        _seedMedication(
          frequency: 'Twice daily',
          remindersEnabled: true,
          reminderTimes: const ['07:30', '19:30'],
        ),
      );

      expect(tester.widget<AppToggle>(find.byType(AppToggle)).value, isTrue);
      expect(find.byType(ReminderTimeRow), findsNWidgets(2));

      await _save(tester);
      expect(_savedMedication().reminderTimes, ['07:30', '19:30']);
    });
  });
}
