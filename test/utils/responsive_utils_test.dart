import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/utils/responsive_utils.dart';

// Wraps ResponsiveLayout inside a widget that constrains its width via a
// tight BoxConstraints, forcing LayoutBuilder to report the desired width.
Widget buildTestWidget({
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

// Renders a Builder with a MediaQuery override so context extension getters
// (which read MediaQuery.sizeOf) see the desired width.
Widget buildContextProbe({
  required double width,
  required ValueSetter<BuildContext> onContext,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Builder(
        builder: (context) {
          onContext(context);
          return const SizedBox.expand();
        },
      ),
    ),
  );
}

void main() {
  group('ResponsiveLayout', () {
    testWidgets('shows mobile builder at 400px', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        width: 400,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        desktop: (_) => const Text('desktop'),
      ));
      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('shows tablet builder at 1000px', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        width: 1000,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        desktop: (_) => const Text('desktop'),
      ));
      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });

    testWidgets('shows desktop builder at 1300px', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        width: 1300,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        desktop: (_) => const Text('desktop'),
      ));
      expect(find.text('desktop'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });

    testWidgets('falls back to mobile when tablet not provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        width: 1000,
        mobile: (_) => const Text('mobile'),
      ));
      expect(find.text('mobile'), findsOneWidget);
    });
  });

  group('ResponsiveContext extension — isTablet consistency with ResponsiveLayout', () {
    testWidgets(
        'at 800px: isMobile == false, isTablet == false (matches ResponsiveLayout mobile)',
        (tester) async {
      BuildContext? capturedContext;
      await tester.pumpWidget(buildContextProbe(
        width: 800,
        onContext: (ctx) => capturedContext = ctx,
      ));
      await tester.pump();

      expect(capturedContext, isNotNull);
      expect(capturedContext!.isMobile, isFalse,
          reason: 'screenWidth 800 >= kMobileBreakpoint 600, so isMobile should be false');
      expect(capturedContext!.isTablet, isFalse,
          reason: 'screenWidth 800 < kTabletBreakpoint 960, so isTablet should be false — '
              'consistent with ResponsiveLayout showing the mobile builder');

      // Confirm ResponsiveLayout also renders mobile at 800px
      await tester.pumpWidget(buildTestWidget(
        width: 800,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        desktop: (_) => const Text('desktop'),
      ));
      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('at 1000px: isTablet == true (matches ResponsiveLayout tablet)',
        (tester) async {
      BuildContext? capturedContext;
      await tester.pumpWidget(buildContextProbe(
        width: 1000,
        onContext: (ctx) => capturedContext = ctx,
      ));
      await tester.pump();

      expect(capturedContext, isNotNull);
      expect(capturedContext!.isTablet, isTrue,
          reason: 'screenWidth 1000 is in [kTabletBreakpoint 960, kDesktopBreakpoint 1200)');

      // Confirm ResponsiveLayout also renders tablet at 1000px
      await tester.pumpWidget(buildTestWidget(
        width: 1000,
        mobile: (_) => const Text('mobile'),
        tablet: (_) => const Text('tablet'),
        desktop: (_) => const Text('desktop'),
      ));
      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });
  });
}
