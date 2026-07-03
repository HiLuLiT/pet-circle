import 'package:flutter/material.dart';

import '../theme/semantic/color_scheme.dart';
import '../theme/tokens/spacing.dart';

/// A horizontal, pill-shaped progress bar for the Pet Circle v3 /
/// Claude-Design palette.
///
/// Mirrors the Figma "Views / Progress Bars" component (node 469:813): a
/// fully-rounded track with a purple fill indicator that grows from the
/// leading edge to reflect [value].
///
/// - Track defaults to [AppSemanticColors.surfaceRecessed] — a light warm
///   neutral that reads as an empty track against the cream app background.
/// - Fill defaults to [AppSemanticColors.primary] (purple #7E5CE0).
/// - Both the track and the fill are pill-rounded
///   ([AppRadiiTokens.pcPill]).
///
/// This widget is intentionally stateless — the caller owns [value] and
/// rebuilds with a new fraction. [value] is clamped to the 0.0–1.0 range.
///
/// Example:
/// ```dart
/// ProgressBar(value: remainingSeconds / totalSeconds)
/// ```
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.trackColor,
    this.fillColor,
  });

  /// Progress fraction in the range 0.0–1.0. Values outside the range are
  /// clamped.
  final double value;

  /// Height (thickness) of the bar in logical pixels.
  final double height;

  /// Track (empty) color. Defaults to
  /// [AppSemanticColors.surfaceRecessed].
  final Color? trackColor;

  /// Fill (indicator) color. Defaults to [AppSemanticColors.primary].
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);
    final clamped = value.clamp(0.0, 1.0);
    final BorderRadius radius =
        BorderRadius.circular(AppRadiiTokens.pcPill);
    final Color track = trackColor ?? colors.surfaceRecessed;
    final Color fill = fillColor ?? colors.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: track,
                borderRadius: radius,
              ),
            ),
            FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: clamped,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: radius,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
