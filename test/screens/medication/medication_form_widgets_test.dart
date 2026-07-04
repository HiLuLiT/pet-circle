import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/medication/medication_form_widgets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';

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

      // Tap the trigger (the currently selected value) to open the
      // inline AppDropdown option list.
      await tester.tap(find.text('Once daily'));
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

      // Open the inline option list, then choose a new option.
      await tester.tap(find.text('Once daily'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Twice daily').last);
      await tester.pumpAndSettle();

      // onChanged reports the canonical (non-localised) value.
      expect(selected, 'Twice daily');
    });
  });

  // ---------------------------------------------------------------------------
  // FrequencyChipSelector (Figma node 402-2388 — wrapped pill chips)
  // ---------------------------------------------------------------------------
  group('FrequencyChipSelector', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        FrequencyChipSelector(
          label: 'Frequency *',
          value: 'Once daily',
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FrequencyChipSelector), findsOneWidget);
    });

    testWidgets('shows all three options as chips at once', (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      await tester.pumpWidget(testApp(
        FrequencyChipSelector(
          label: 'Frequency *',
          value: 'Once daily',
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Unlike DropdownField, every option is visible without opening
      // anything — no separate "open" interaction needed.
      expect(find.text('Once daily'), findsOneWidget);
      expect(find.text('Twice daily'), findsOneWidget);
      expect(find.text('As needed'), findsOneWidget);
    });

    testWidgets('calls onChanged with the canonical value when tapped',
        (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);

      String? selected;
      await tester.pumpWidget(testApp(
        FrequencyChipSelector(
          label: 'Frequency *',
          value: 'Once daily',
          onChanged: (v) => selected = v,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Twice daily'));
      await tester.pumpAndSettle();

      expect(selected, 'Twice daily');
    });

    testWidgets('selected chip uses accentPeriwinkleTile background',
        (tester) async {
      suppressOverflowErrors();
      _setSheetSize(tester);
      late BuildContext capturedContext;

      await tester.pumpWidget(testApp(
        Builder(builder: (ctx) {
          capturedContext = ctx;
          return FrequencyChipSelector(
            label: 'Frequency *',
            value: 'Twice daily',
            onChanged: (_) {},
          );
        }),
      ));
      await tester.pumpAndSettle();

      final tileColor = AppSemanticColors.of(capturedContext).accentPeriwinkleTile;
      final containers = tester.widgetList<Container>(find.byType(Container)).where(
        (c) => c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == tileColor,
      );
      expect(containers.isNotEmpty, isTrue);
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
}
