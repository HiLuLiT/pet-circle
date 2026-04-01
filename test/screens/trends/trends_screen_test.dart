import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/trends/trends_screen.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('TrendsScreen', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TrendsScreen), findsOneWidget);
    });

    testWidgets('shows health trends title', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Health Trends'), findsOneWidget);
    });

    testWidgets('shows period dropdown', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      // Default period is "Last 7 days"
      expect(find.text('Last 7 days'), findsOneWidget);
    });

    testWidgets('shows export button', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Export'), findsOneWidget);
      expect(find.byIcon(Icons.file_download), findsOneWidget);
    });

    testWidgets('shows chart legend badges', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Normal (<30)'), findsOneWidget);
      expect(find.text('Elevated (30-40)'), findsOneWidget);
      expect(find.text('Alert (>40)'), findsOneWidget);
    });
  });
}
