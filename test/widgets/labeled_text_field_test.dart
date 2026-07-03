import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/labeled_text_field.dart';

import '../helpers/test_app.dart';

void main() {
  group('LabeledTextField', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const LabeledTextField(label: 'Name', hintText: 'Enter name'),
      ));
      expect(find.byType(LabeledTextField), findsOneWidget);
    });

    // ── Variant / state tests ──────────────────────────────────────────────
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(testApp(
        const LabeledTextField(label: 'Email', hintText: 'you@example.com'),
      ));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(testApp(
        const LabeledTextField(label: 'Name', hintText: 'John Doe'),
      ));
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('uses provided controller', (tester) async {
      final controller = TextEditingController(text: 'preset');
      await tester.pumpWidget(testApp(
        LabeledTextField(
          label: 'Field',
          hintText: 'hint',
          controller: controller,
        ),
      ));
      expect(find.text('preset'), findsOneWidget);
      controller.dispose();
    });

    // ── Interaction test ────────────────────────────────────────────────────
    testWidgets('calls onChanged when text is entered', (tester) async {
      String? changedValue;
      await tester.pumpWidget(testApp(
        LabeledTextField(
          label: 'Input',
          hintText: 'type here',
          onChanged: (v) => changedValue = v,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'hello');
      expect(changedValue, 'hello');
    });

    // ── Theme token tests (PC v3 / Claude-Design) ───────────────────────────
    testWidgets('label uses semantic labelSm style', (tester) async {
      await tester.pumpWidget(testApp(
        const LabeledTextField(label: 'Label', hintText: 'hint'),
      ));

      final label = tester.widget<Text>(find.text('Label'));
      expect(label.style?.fontSize, AppSemanticTextStyles.labelSm.fontSize);
      expect(label.style?.fontWeight, AppSemanticTextStyles.labelSm.fontWeight);
    });

    testWidgets('input fill color is semantic surface', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(testApp(
        Builder(builder: (ctx) {
          capturedContext = ctx;
          return const LabeledTextField(label: 'F', hintText: 'h');
        }),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(
        textField.decoration?.fillColor,
        AppSemanticColors.of(capturedContext).surface,
      );
    });

    testWidgets('hint text color is semantic textTertiary', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(testApp(
        Builder(builder: (ctx) {
          capturedContext = ctx;
          return const LabeledTextField(label: 'F', hintText: 'placeholder');
        }),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(
        textField.decoration?.hintStyle?.color,
        AppSemanticColors.of(capturedContext).textTertiary,
      );
    });

    testWidgets('border radius is pcField (14)', (tester) async {
      await tester.pumpWidget(testApp(
        const LabeledTextField(label: 'F', hintText: 'h'),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      final border = textField.decoration?.enabledBorder as OutlineInputBorder;
      expect(
        border.borderRadius,
        BorderRadius.circular(AppRadiiTokens.pcField),
      );
    });

    testWidgets('enabled border is 1px hairline', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(testApp(
        Builder(builder: (ctx) {
          capturedContext = ctx;
          return const LabeledTextField(label: 'F', hintText: 'h');
        }),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      final border = textField.decoration?.enabledBorder as OutlineInputBorder;
      expect(border.borderSide.width, 1);
      expect(
        border.borderSide.color,
        AppSemanticColors.of(capturedContext).hairline,
      );
    });

    testWidgets('focused border is 3px accentPurple ring', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(testApp(
        Builder(builder: (ctx) {
          capturedContext = ctx;
          return const LabeledTextField(label: 'F', hintText: 'h');
        }),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      final border = textField.decoration?.focusedBorder as OutlineInputBorder;
      expect(border.borderSide.width, 3);
      expect(
        border.borderSide.color,
        AppSemanticColors.of(capturedContext).accentPurple,
      );
    });

    testWidgets('input style uses pcBody (16px Instrument Sans)', (tester) async {
      await tester.pumpWidget(testApp(
        const LabeledTextField(label: 'F', hintText: 'h'),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontSize, AppSemanticTextStyles.pcBody.fontSize);
    });

    testWidgets('spacing between label and field is sm (8)', (tester) async {
      await tester.pumpWidget(testApp(
        const LabeledTextField(label: 'L', hintText: 'h'),
      ));

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacer = sizedBoxes.where(
        (sb) => sb.height == AppSpacingTokens.sm,
      );
      expect(spacer.isNotEmpty, isTrue);
    });
  });
}
