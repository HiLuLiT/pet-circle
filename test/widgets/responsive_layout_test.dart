import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/utils/responsive_utils.dart';

/// Builds a ResponsiveLayout inside a constrained OverflowBox so that
/// LayoutBuilder reports the desired [width].
Widget _buildTestWidget({
  required double width,
  required WidgetBuilder mobile,
  WidgetBuilder? tablet,
  WidgetBuilder? desktop,
}) {
  return MaterialApp(
    home: Scaffold(
      body: OverflowBox(
        minWidth: width,
        maxWidth: width,
        alignment: Alignment.topLeft,
        child: ResponsiveLayout(
          mobile: mobile,
          tablet: tablet,
          desktop: desktop,
        ),
      ),
    ),
  );
}

void main() {
  group('ResponsiveLayout — breakpoint selection', () {
    testWidgets('renders mobile builder at 400px width', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        width: 400,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        desktop: (_) => const Text('desktop'),
      ));

      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
      expect(find.text('desktop'), findsNothing);
    });

    testWidgets('renders tablet builder at 1000px width', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        width: 1000,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        desktop: (_) => const Text('desktop'),
      ));

      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
      expect(find.text('desktop'), findsNothing);
    });

    testWidgets('renders desktop builder at 1300px width', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        width: 1300,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        desktop: (_) => const Text('desktop'),
      ));

      expect(find.text('desktop'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });

    testWidgets('falls back to mobile when tablet builder is null',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        width: 1000,
        mobile: (_) => const Text('mobile'),
        // tablet intentionally null
      ));

      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('falls back to tablet when desktop builder is null',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        width: 1300,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        // desktop intentionally null
      ));

      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('falls back to mobile when both tablet and desktop are null',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        width: 1300,
        mobile: (_) => const Text('mobile'),
      ));

      expect(find.text('mobile'), findsOneWidget);
    });
  });

  group('ResponsiveLayout — breakpoint boundaries', () {
    testWidgets('at exactly kTabletBreakpoint selects tablet', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        width: kTabletBreakpoint,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
      ));

      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });

    testWidgets('just below kTabletBreakpoint selects mobile', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        width: kTabletBreakpoint - 1,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
      ));

      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('at exactly kDesktopBreakpoint selects desktop',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        width: kDesktopBreakpoint,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        desktop: (_) => const Text('desktop'),
      ));

      expect(find.text('desktop'), findsOneWidget);
    });
  });
}
