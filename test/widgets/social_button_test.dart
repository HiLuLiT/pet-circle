import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/widgets/social_button.dart';

import '../helpers/test_app.dart';

void main() {
  group('SocialButton', () {
    testWidgets('renders label and leading icon', (tester) async {
      await tester.pumpWidget(testApp(
        SocialButton(
          icon: const Icon(Icons.apple),
          label: 'Continue with Apple',
          onTap: () {},
        ),
      ));

      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('uses an OutlinedButton internally', (tester) async {
      await tester.pumpWidget(testApp(
        SocialButton(
          icon: const Icon(Icons.apple),
          label: 'Continue with Apple',
          onTap: () {},
        ),
      ));

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(testApp(
        SocialButton(
          icon: const Icon(Icons.apple),
          label: 'Continue with Apple',
          onTap: () => tapped++,
        ),
      ));

      await tester.tap(find.byType(SocialButton));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('is disabled when onTap is null', (tester) async {
      await tester.pumpWidget(testApp(
        const SocialButton(
          icon: Icon(Icons.apple),
          label: 'Continue with Apple',
          onTap: null,
        ),
      ));

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('label uses 600 (SemiBold) weight', (tester) async {
      await tester.pumpWidget(testApp(
        SocialButton(
          icon: const Icon(Icons.apple),
          label: 'Continue with Apple',
          onTap: () {},
        ),
      ));

      final text = tester.widget<Text>(find.text('Continue with Apple'));
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('is full width (52 high) via SizedBox', (tester) async {
      await tester.pumpWidget(testApp(
        SocialButton(
          icon: const Icon(Icons.apple),
          label: 'Continue with Apple',
          onTap: () {},
        ),
      ));

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final match = sizedBoxes.where(
        (sb) => sb.width == double.infinity && sb.height == 52,
      );
      expect(match.isNotEmpty, isTrue);
    });
  });
}
