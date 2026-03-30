import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/primary_button.dart';

/// Wraps a widget with MaterialApp + theme so AppColorsTheme.of works.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PrimaryButton', () {
    testWidgets('filled variant renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Save',
          variant: PrimaryButtonVariant.filled,
          onPressed: () {},
        ),
      ));

      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('outlined variant renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Cancel',
          variant: PrimaryButtonVariant.outlined,
          onPressed: () {},
        ),
      ));

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('disabled button (onPressed: null) does not respond to tap',
        (tester) async {
      var tapped = false;
      // First pump an enabled button reference, then disabled
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Disabled',
          onPressed: null,
        ),
      ));

      // ElevatedButton with null onPressed should have disabled state
      final button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      // Tapping should not trigger anything
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Add',
          icon: Icons.add,
          onPressed: () {},
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('uses ConstrainedBox with specified minHeight',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Tall',
          minHeight: 80,
          onPressed: () {},
        ),
      ));

      // Find the ConstrainedBox that has our custom minHeight
      final boxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .where((cb) => cb.constraints.minHeight == 80.0);
      expect(boxes.isNotEmpty, isTrue,
          reason: 'Should contain a ConstrainedBox with minHeight 80');
    });

    testWidgets('full width via SizedBox width: infinity', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Wide',
          onPressed: () {},
        ),
      ));

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final fullWidth = sizedBoxes.where((sb) => sb.width == double.infinity);
      expect(fullWidth.isNotEmpty, isTrue);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Tap Me',
          onPressed: () => callCount++,
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pump();
      expect(callCount, 1);
    });
  });
}
