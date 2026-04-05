import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/bottom_nav_bar.dart';

/// Wraps a widget with MaterialApp + theme so AppColorsTheme.of works.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PrimaryButton accessibility', () {
    testWidgets('has a Semantics node with the button label text',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Save', onPressed: () {}),
      ));

      // ElevatedButton automatically creates a Semantics node whose label
      // matches the child Text widget.
      final semantics = tester.getSemantics(find.text('Save'));
      expect(semantics.label, 'Save');
    });

    testWidgets('disabled button has disabled semantics', (tester) async {
      await tester.pumpWidget(_wrap(
        const PrimaryButton(label: 'Submit', onPressed: null),
      ));

      final semanticsNode = tester.getSemantics(find.text('Submit'));
      final data = semanticsNode.getSemanticsData();
      // A disabled ElevatedButton has no tap action in the semantics tree.
      expect(data.hasAction(SemanticsAction.tap), isFalse);
    });
  });

  group('BottomNavBar accessibility', () {
    Widget buildNav({int selectedIndex = 0}) {
      return _wrap(
        BottomNavBar(
          selectedIndex: selectedIndex,
          onTap: (_) {},
        ),
      );
    }

    testWidgets('Home nav item has semantic label "Home"', (tester) async {
      await tester.pumpWidget(buildNav());
      await tester.pump();

      // The Semantics widget wraps the Column that contains both
      // the Icon and Text, so its merged label includes "Home".
      expect(
        find.bySemanticsLabel(RegExp('Home')),
        findsOneWidget,
        reason: 'Home tab must expose a "Home" semantics label',
      );
    });

    testWidgets('Trends nav item has semantic label "Trends"', (tester) async {
      await tester.pumpWidget(buildNav());
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp('Trends')),
        findsOneWidget,
        reason: 'Trends tab must expose a "Trends" semantics label',
      );
    });

    testWidgets('Circle nav item has semantic label "Circle"', (tester) async {
      await tester.pumpWidget(buildNav());
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp('Circle')),
        findsOneWidget,
        reason: 'Circle tab must expose a "Circle" semantics label',
      );
    });

    testWidgets('Mesure nav item has semantic label "Mesure"',
        (tester) async {
      await tester.pumpWidget(buildNav());
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp('Mesure')),
        findsOneWidget,
        reason: 'Mesure tab must expose a "Mesure" semantics label',
      );
    });

    testWidgets('Medicine nav item has semantic label "Medicine"',
        (tester) async {
      await tester.pumpWidget(buildNav());
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp('Medicine')),
        findsOneWidget,
        reason: 'Medicine tab must expose a "Medicine" semantics label',
      );
    });

    testWidgets('all five semantic labels present simultaneously',
        (tester) async {
      await tester.pumpWidget(buildNav(selectedIndex: 2));
      await tester.pump();

      for (final label in ['Home', 'Trends', 'Circle', 'Mesure', 'Medicine']) {
        expect(
          find.bySemanticsLabel(RegExp(label)),
          findsOneWidget,
          reason: 'Expected semantic label "$label" to be present',
        );
      }
    });
  });
}
