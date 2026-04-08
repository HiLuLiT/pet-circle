import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/diary/diary_screen.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('DiaryScreen', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const DiaryScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DiaryScreen), findsOneWidget);
    });

    testWidgets('shows "Diary" text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const DiaryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Diary'), findsOneWidget);
    });

    testWidgets('shows "Coming soon" text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const DiaryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon'), findsOneWidget);
    });

    testWidgets('shows menu_book icon', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const DiaryScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('renders Scaffold when showScaffold=true (default)',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const DiaryScreen()));
      await tester.pumpAndSettle();

      // testApp already wraps in a Scaffold, but DiaryScreen(showScaffold:true)
      // adds its own inner Scaffold with a SafeArea.
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });

    testWidgets('renders body-only when showScaffold=false', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const DiaryScreen(showScaffold: false)));
      await tester.pumpAndSettle();

      // Content is still visible
      expect(find.text('Diary'), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
    });

    testWidgets('content is centered on screen', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const DiaryScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });

    testWidgets('renders in dark mode without error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const DiaryScreen(), darkMode: true));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Diary'), findsOneWidget);
    });
  });
}
