import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/onboarding/onboarding_flow.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('OnboardingFlow', () {
    testWidgets('renders step 1 on launch', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingFlow), findsOneWidget);
      // Step 1 should be visible — it uses OnboardingShell
      expect(find.byType(OnboardingShell), findsOneWidget);
    });

    testWidgets('shows pet name field on step 1', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      expect(find.text("Pet's Name"), findsOneWidget);
    });

    testWidgets('shows next button on step 1', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
    });
  });
}
