import 'package:flutter/material.dart';

// Breakpoints
const double kMobileBreakpoint = 600.0;
const double kTabletBreakpoint = 960.0;
const double kDesktopBreakpoint = 1200.0;

// Extension on BuildContext for quick access
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < kMobileBreakpoint;
  bool get isTablet =>
      screenWidth >= kTabletBreakpoint && screenWidth < kDesktopBreakpoint;
  bool get isDesktop => screenWidth >= kDesktopBreakpoint;
  bool get isWide => screenWidth >= kTabletBreakpoint;
}

// Helper for max content width (centers content on large screens)
double responsiveMaxWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= kDesktopBreakpoint) return 1140.0;
  if (width >= kTabletBreakpoint) return 720.0;
  return double.infinity;
}

// Responsive layout widget — selects builder based on screen width
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= kDesktopBreakpoint && desktop != null) {
          return desktop!(context);
        }
        if (width >= kTabletBreakpoint && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}
