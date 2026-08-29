import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/widgets/reminder_time_row.dart';

import '../helpers/test_app.dart';

void main() {
  group('ReminderTimeRow', () {
    testWidgets('renders the label and the formatted time', (tester) async {
      await tester.pumpWidget(
        testApp(
          ReminderTimeRow(
            label: 'First dose',
            value: const TimeOfDay(hour: 9, minute: 0),
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('First dose'), findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);
    });

    testWidgets('reports the picked time through onChanged', (tester) async {
      TimeOfDay? picked;
      await tester.pumpWidget(
        testApp(
          ReminderTimeRow(
            label: 'Reminder time',
            value: const TimeOfDay(hour: 9, minute: 0),
            onChanged: (value) => picked = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('9:00 AM'));
      await tester.pumpAndSettle();

      // The dialog opens in keyboard-entry mode; confirming without editing
      // returns the initial time.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(picked, const TimeOfDay(hour: 9, minute: 0));
    });

    testWidgets('does not report anything when the picker is cancelled', (
      tester,
    ) async {
      var called = false;
      await tester.pumpWidget(
        testApp(
          ReminderTimeRow(
            label: 'Reminder time',
            value: const TimeOfDay(hour: 21, minute: 30),
            onChanged: (_) => called = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('9:30 PM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });
  });
}
