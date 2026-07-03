import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/widgets/responsive_grid.dart';

import '../helpers/test_app.dart';

void main() {
  group('ResponsiveGrid', () {
    // Forces the grid's LayoutBuilder to observe an exact width by giving it a
    // tight-width parent inside an unbounded horizontal scroll view.
    Widget gridIn(double width, {required ResponsiveGrid grid}) {
      return testApp(
        Align(
          alignment: Alignment.topLeft,
          child: OverflowBox(
            minWidth: width,
            maxWidth: width,
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, child: grid),
          ),
        ),
      );
    }

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        ResponsiveGrid(
          maxCrossAxisCount: 3,
          minItemWidth: 280,
          children: const [Text('a'), Text('b')],
        ),
      ));
      expect(find.byType(ResponsiveGrid), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('renders all children', (tester) async {
      await tester.pumpWidget(testApp(
        ResponsiveGrid(
          maxCrossAxisCount: 3,
          minItemWidth: 280,
          children: const [
            Text('one'),
            Text('two'),
            Text('three'),
          ],
        ),
      ));

      expect(find.text('one'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);
      expect(find.text('three'), findsOneWidget);
    });

    testWidgets('uses one column on a narrow viewport', (tester) async {
      await tester.pumpWidget(gridIn(
        300,
        grid: ResponsiveGrid(
          maxCrossAxisCount: 3,
          minItemWidth: 280,
          children: const [Text('a'), Text('b'), Text('c')],
        ),
      ));
      await tester.pump();

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      // 300 / 280 -> floor 1, clamped to [1, 3].
      expect(delegate.crossAxisCount, 1);
    });

    testWidgets('clamps column count to maxCrossAxisCount on wide viewport',
        (tester) async {
      await tester.pumpWidget(gridIn(
        2000,
        grid: ResponsiveGrid(
          maxCrossAxisCount: 3,
          minItemWidth: 280,
          children: const [Text('a'), Text('b'), Text('c')],
        ),
      ));
      await tester.pump();

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      // 2000 / 280 -> floor 7, clamped to max 3.
      expect(delegate.crossAxisCount, 3);
    });

    testWidgets('honours custom childAspectRatio', (tester) async {
      await tester.pumpWidget(gridIn(
        600,
        grid: ResponsiveGrid(
          maxCrossAxisCount: 3,
          minItemWidth: 280,
          childAspectRatio: 3.3,
          children: const [Text('a'), Text('b')],
        ),
      ));
      await tester.pump();

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.childAspectRatio, 3.3);
    });
  });
}
