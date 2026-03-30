import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/status_badge.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('StatusBadge', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Normal', color: AppColors.lightBlue),
      ));

      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('renders with Normal status color (lightBlue)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Normal', color: AppColors.lightBlue),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.lightBlue);
    });

    testWidgets('renders with Elevated status color (lightYellow)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Elevated', color: AppColors.lightYellow),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.lightYellow);
    });

    testWidgets('renders with Critical status color (cherry)', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Critical', color: AppColors.cherry),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.cherry);
    });

    testWidgets('has correct border radius', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Test', color: AppColors.lightBlue),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        const BorderRadius.all(AppRadii.small),
      );
    });

    testWidgets('uses badge text style', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Normal', color: AppColors.lightBlue),
      ));

      final text = tester.widget<Text>(find.text('Normal'));
      expect(text.style?.fontSize, AppTextStyles.badge.fontSize);
      expect(text.style?.fontWeight, AppTextStyles.badge.fontWeight);
    });
  });
}
