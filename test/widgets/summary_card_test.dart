import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';
import 'package:pet_circle/widgets/summary_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('SummaryCard', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const SummaryCard(
          iconColor: Color(0xFFEEEEEE),
          icon: Icons.check_circle_outline,
          value: '3',
          label: 'Normal Status',
        ),
      ));
      expect(find.byType(SummaryCard), findsOneWidget);
    });

    testWidgets('shows the value and label text', (tester) async {
      await tester.pumpWidget(testApp(
        const SummaryCard(
          iconColor: Color(0xFFEEEEEE),
          icon: Icons.bar_chart,
          value: '12',
          label: 'Measurements this week',
        ),
      ));

      expect(find.text('12'), findsOneWidget);
      expect(find.text('Measurements this week'), findsOneWidget);
    });

    testWidgets('renders the supplied icon', (tester) async {
      await tester.pumpWidget(testApp(
        const SummaryCard(
          iconColor: Color(0xFFEEEEEE),
          icon: Icons.warning_amber_outlined,
          value: '1',
          label: 'Need Attention',
        ),
      ));

      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('is built on a NeumorphicCard', (tester) async {
      await tester.pumpWidget(testApp(
        const SummaryCard(
          iconColor: Color(0xFFEEEEEE),
          icon: Icons.check_circle_outline,
          value: '0',
          label: 'Normal Status',
        ),
      ));

      expect(find.byType(NeumorphicCard), findsOneWidget);
    });

    testWidgets('icon tile uses the supplied iconColor', (tester) async {
      const tile = Color(0xFFABCDEF);
      await tester.pumpWidget(testApp(
        const SummaryCard(
          iconColor: tile,
          icon: Icons.check_circle_outline,
          value: '2',
          label: 'Normal Status',
        ),
      ));

      final hasTile = tester
          .widgetList<Container>(find.byType(Container))
          .any((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && decoration.color == tile;
      });
      expect(hasTile, isTrue);
    });

    testWidgets('icon colour is textPrimary', (tester) async {
      await tester.pumpWidget(testApp(
        const SummaryCard(
          iconColor: Color(0xFFEEEEEE),
          icon: Icons.bar_chart,
          value: '5',
          label: 'Measurements this week',
        ),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.bar_chart));
      expect(icon.color, AppSemanticColors.light.textPrimary);
    });
  });
}
