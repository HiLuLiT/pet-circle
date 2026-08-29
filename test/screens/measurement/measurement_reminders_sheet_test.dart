import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/measurement/measurement_reminders_sheet.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/widgets/app_toggle.dart';
import 'package:pet_circle/widgets/reminder_time_row.dart';
import 'package:pet_circle/widgets/segmented_control.dart';

import '../../helpers/test_app.dart';

void main() {
  setUp(settingsStore.reset);
  tearDown(settingsStore.reset);

  group('MeasurementRemindersSheet', () {
    testWidgets('renders frequency and time controls when reminders are on', (
      tester,
    ) async {
      await settingsStore.setMeasurementRemindersEnabled(true);
      await tester.pumpWidget(testApp(const MeasurementRemindersSheet()));

      expect(find.byType(AppSegmentedControl), findsOneWidget);
      expect(find.byType(ReminderTimeRow), findsOneWidget);
    });

    testWidgets('hides frequency and time controls when reminders are off', (
      tester,
    ) async {
      await settingsStore.setMeasurementRemindersEnabled(false);
      await tester.pumpWidget(testApp(const MeasurementRemindersSheet()));

      expect(find.byType(AppToggle), findsOneWidget);
      expect(find.byType(AppSegmentedControl), findsNothing);
      expect(find.byType(ReminderTimeRow), findsNothing);
    });

    testWidgets('toggling writes through to settingsStore', (tester) async {
      await settingsStore.setMeasurementRemindersEnabled(true);
      await tester.pumpWidget(testApp(const MeasurementRemindersSheet()));

      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();

      expect(settingsStore.measurementRemindersEnabled, isFalse);
      // The sheet listens to the store, so the dependent rows disappear
      // without the caller having to rebuild it.
      expect(find.byType(AppSegmentedControl), findsNothing);
    });

    testWidgets('choosing a cadence updates frequency and derived days', (
      tester,
    ) async {
      await settingsStore.setMeasurementRemindersEnabled(true);
      await settingsStore.setMeasurementReminderFrequency(3);
      await tester.pumpWidget(testApp(const MeasurementRemindersSheet()));

      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      expect(settingsStore.measurementReminderFrequency, 7);
      expect(settingsStore.measurementReminderDays, [1, 2, 3, 4, 5, 6, 7]);
    });

    testWidgets('an unrecognised stored frequency still renders a selection', (
      tester,
    ) async {
      // Guards the `labels[frequency] ?? labels[3]!` fallback: a document
      // written with a cadence outside {2,3,7} must not leave every segment
      // looking inactive.
      await settingsStore.setMeasurementRemindersEnabled(true);
      await settingsStore.setMeasurementReminderDays(const [1, 2, 4, 6]);
      await tester.pumpWidget(testApp(const MeasurementRemindersSheet()));

      expect(settingsStore.measurementReminderFrequency, 4);
      expect(
        tester.widget<AppSegmentedControl>(find.byType(AppSegmentedControl)).value,
        '3x / week',
      );
    });

    testWidgets('picking a time writes through to settingsStore', (
      tester,
    ) async {
      await settingsStore.setMeasurementRemindersEnabled(true);
      // A morning start keeps the picker's AM/PM selector on AM, so the
      // typed hour lands as-is rather than being shifted into the afternoon.
      await settingsStore.setMeasurementReminderTime(8, 0);
      await tester.pumpWidget(testApp(const MeasurementRemindersSheet()));

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // The picker opens in keyboard-entry mode (see ReminderTimeRow), so the
      // hour/minute fields are plain text inputs.
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '7');
      await tester.enterText(fields.at(1), '45');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(settingsStore.measurementReminderHour, 7);
      expect(settingsStore.measurementReminderMinute, 45);
    });
  });
}
