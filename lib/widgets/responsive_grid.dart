import 'package:flutter/material.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// A responsive, non-scrolling grid that picks its column count from the
/// available width.
///
/// The number of columns is `(width / minItemWidth)` floored, clamped to
/// `[1, maxCrossAxisCount]`. Used to lay out pet cards and summary cards on
/// the vet and care-circle dashboards.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.minItemWidth,
    required this.maxCrossAxisCount,
    this.childAspectRatio = 0.85,
  });

  final List<Widget> children;

  /// Minimum width a single item should have before adding another column.
  final double minItemWidth;

  /// Upper bound on the number of columns.
  final int maxCrossAxisCount;

  /// Width-to-height ratio of each grid cell.
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final count =
            (width / minItemWidth).floor().clamp(1, maxCrossAxisCount);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: count,
          crossAxisSpacing: AppSpacingTokens.lg,
          mainAxisSpacing: AppSpacingTokens.lg,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}
