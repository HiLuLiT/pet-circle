import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/toggle_pill.dart';

Widget _wrap(Widget child, {VoidCallback? onTap}) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: onTap,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('TogglePill', () {
    testWidgets('isOn: true uses full chocolate background', (tester) async {
      await tester.pumpWidget(_wrap(const TogglePill(isOn: true)));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.chocolate);
    });

    testWidgets('isOn: false uses faded chocolate background', (tester) async {
      await tester.pumpWidget(_wrap(const TogglePill(isOn: false)));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      // When off, color is chocolate with 0.2 opacity
      expect(decoration.color, isNot(AppColors.chocolate));
      expect(decoration.color?.opacity, closeTo(0.2, 0.01));
    });

    testWidgets('isOn: true aligns knob to the right', (tester) async {
      await tester.pumpWidget(_wrap(const TogglePill(isOn: true)));

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('isOn: false aligns knob to the left', (tester) async {
      await tester.pumpWidget(_wrap(const TogglePill(isOn: false)));

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('has fixed size of 75x36', (tester) async {
      await tester.pumpWidget(_wrap(const TogglePill(isOn: true)));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, 75);
      expect(container.constraints?.maxHeight, 36);
    });

    testWidgets('GestureDetector wrapping TogglePill calls onTap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        const TogglePill(isOn: false),
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(TogglePill));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
