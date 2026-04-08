import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/medication/medication_form_widgets.dart';
import 'package:pet_circle/widgets/toggle_pill.dart';

import '../../helpers/helpers.dart';
import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/test_http_overrides.dart';

void _setSheetSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(480, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  // ---------------------------------------------------------------------------
  // ValidatedFormField
  // ---------------------------------------------------------------------------
  group('ValidatedFormField', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        Form(
          child: ValidatedFormField(
            label: 'Medication Name *',
            hint: 'e.g., Furosemide',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ValidatedFormField), findsOneWidget);
    });

    testWidgets('shows label text', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        Form(
          child: ValidatedFormField(
            label: 'Medication Name *',
            hint: 'e.g., Furosemide',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Medication Name *'), findsOneWidget);
    });

    testWidgets('shows hint text in text field', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        Form(
          child: ValidatedFormField(
            label: 'Medication Name *',
            hint: 'e.g., Furosemide',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('e.g., Furosemide'), findsOneWidget);
    });

    testWidgets('accepts text input via controller', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      final controller = TextEditingController();
      await tester.pumpWidget(testApp(
        Form(
          child: ValidatedFormField(
            label: 'Dosage *',
            hint: 'e.g., 5mg',
            controller: controller,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '10mg');
      await tester.pump();

      expect(controller.text, '10mg');
    });

    testWidgets('shows validation error when validator returns message', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(testApp(
        Form(
          key: formKey,
          child: ValidatedFormField(
            label: 'Medication Name *',
            hint: 'e.g., Furosemide',
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Required' : null,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // DatePickerField
  // ---------------------------------------------------------------------------
  group('DatePickerField', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      final controller = TextEditingController();
      await tester.pumpWidget(testApp(
        Form(
          child: DatePickerField(
            label: 'Start Date *',
            controller: controller,
            onTap: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerField), findsOneWidget);
    });

    testWidgets('shows label', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      final controller = TextEditingController();
      await tester.pumpWidget(testApp(
        Form(
          child: DatePickerField(
            label: 'Start Date *',
            controller: controller,
            onTap: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Start Date *'), findsOneWidget);
    });

    testWidgets('shows calendar icon', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      final controller = TextEditingController();
      await tester.pumpWidget(testApp(
        Form(
          child: DatePickerField(
            label: 'Start Date *',
            controller: controller,
            onTap: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      var tapped = false;
      final controller = TextEditingController();
      await tester.pumpWidget(testApp(
        Form(
          child: DatePickerField(
            label: 'Start Date *',
            controller: controller,
            onTap: () => tapped = true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('is read-only (cannot type directly)', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      final controller = TextEditingController();
      await tester.pumpWidget(testApp(
        Form(
          child: DatePickerField(
            label: 'Start Date *',
            controller: controller,
            onTap: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // DatePickerField wraps a TextFormField with readOnly: true.
      // The underlying EditableText will have readOnly=true.
      final editableText =
          tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.readOnly, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // DropdownField
  // ---------------------------------------------------------------------------
  group('DropdownField', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        DropdownField(
          label: 'Frequency *',
          value: 'Once daily',
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownField), findsOneWidget);
    });

    testWidgets('shows label text', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        DropdownField(
          label: 'Frequency *',
          value: 'Once daily',
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Frequency *'), findsOneWidget);
    });

    testWidgets('shows current selected value', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        DropdownField(
          label: 'Frequency *',
          value: 'Once daily',
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Once daily'), findsOneWidget);
    });

    testWidgets('shows all dropdown options when opened', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        DropdownField(
          label: 'Frequency *',
          value: 'Once daily',
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Twice daily'), findsOneWidget);
      expect(find.text('As needed'), findsOneWidget);
    });

    testWidgets('calls onChanged when a new value is selected', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      String? selected;
      await tester.pumpWidget(testApp(
        DropdownField(
          label: 'Frequency *',
          value: 'Once daily',
          onChanged: (v) => selected = v,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Twice daily').last);
      await tester.pumpAndSettle();

      expect(selected, 'Twice daily');
    });
  });

  // ---------------------------------------------------------------------------
  // ValidatedTextArea
  // ---------------------------------------------------------------------------
  group('ValidatedTextArea', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        Form(
          child: ValidatedTextArea(
            label: 'Additional Notes',
            hint: 'Enter any additional notes here',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ValidatedTextArea), findsOneWidget);
    });

    testWidgets('shows label text', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        Form(
          child: ValidatedTextArea(
            label: 'Additional Notes',
            hint: 'Enter any additional notes here',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Additional Notes'), findsOneWidget);
    });

    testWidgets('shows hint text', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        Form(
          child: ValidatedTextArea(
            label: 'Additional Notes',
            hint: 'Enter any additional notes here',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Enter any additional notes here'), findsOneWidget);
    });

    testWidgets('accepts multi-line input', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      final controller = TextEditingController();
      await tester.pumpWidget(testApp(
        Form(
          child: ValidatedTextArea(
            label: 'Notes',
            hint: 'Notes...',
            controller: controller,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Line 1\nLine 2');
      await tester.pump();

      expect(controller.text, 'Line 1\nLine 2');
    });
  });

  // ---------------------------------------------------------------------------
  // ReminderCard
  // ---------------------------------------------------------------------------
  group('ReminderCard', () {
    testWidgets('renders without error when disabled', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        ReminderCard(enabled: false, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ReminderCard), findsOneWidget);
    });

    testWidgets('renders without error when enabled', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        ReminderCard(enabled: true, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ReminderCard), findsOneWidget);
    });

    testWidgets('shows medication reminders text', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        ReminderCard(enabled: false, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Medication Reminders'), findsOneWidget);
    });

    testWidgets('shows notifications icon', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        ReminderCard(enabled: false, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('shows TogglePill', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        ReminderCard(enabled: true, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TogglePill), findsOneWidget);
    });

    testWidgets('calls onChanged when toggle is tapped', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      bool? toggled;
      await tester.pumpWidget(testApp(
        ReminderCard(enabled: false, onChanged: (v) => toggled = v),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).last);
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('TogglePill reflects enabled state (on)', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        ReminderCard(enabled: true, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      final pill = tester.widget<TogglePill>(find.byType(TogglePill));
      expect(pill.isOn, isTrue);
    });

    testWidgets('TogglePill reflects enabled state (off)', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        ReminderCard(enabled: false, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      final pill = tester.widget<TogglePill>(find.byType(TogglePill));
      expect(pill.isOn, isFalse);
    });
  });
}
