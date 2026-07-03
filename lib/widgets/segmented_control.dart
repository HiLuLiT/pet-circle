import 'package:flutter/material.dart';

import '../theme/semantic/color_scheme.dart';
import '../theme/semantic/text_theme.dart';
import '../theme/tokens/spacing.dart';

/// A pill-shaped segmented control for the Pet Circle v3 / Claude-Design
/// palette.
///
/// Mirrors the React `SegmentedControl` reference component. The outer
/// container uses the recessed surface color and the field-level corner
/// radius ([AppRadiiTokens.pcField] = 14). Each segment is laid out with
/// equal flex so the control fills its parent. The active segment is
/// lifted onto the surface color with a slightly smaller corner radius
/// (10) and bold text; inactive segments are transparent with tertiary
/// text.
///
/// This widget is intentionally stateless — the caller owns the selected
/// value and rebuilds the widget with a new [value] when [onChanged]
/// fires.
///
/// Example:
/// ```dart
/// AppSegmentedControl(
///   options: const ['Day', 'Week', 'Month'],
///   value: _range,
///   onChanged: (v) => setState(() => _range = v),
/// )
/// ```
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
  });

  /// The list of segment labels to render. Must be non-empty.
  final List<String> options;

  /// The currently-selected label. Should match one of [options].
  final String value;

  /// Fired with the tapped label when an inactive segment is pressed.
  /// Null disables interaction (segments still render).
  final ValueChanged<String>? onChanged;

  // ── Layout constants (match the React reference) ──────────────────────────
  static const double _outerPadding = 5;
  static const double _segmentPadding = 11;
  static const double _segmentRadius = 10;
  static const double _fontSize = 15;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.all(_outerPadding),
      decoration: BoxDecoration(
        color: colors.surfaceRecessed,
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcField),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: options
            .map((opt) => _buildSegment(context, colors, opt))
            .toList(growable: false),
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context,
    AppSemanticColors colors,
    String opt,
  ) {
    final isActive = opt == value;
    final activeStyle = AppSemanticTextStyles.pcLabelBold.copyWith(
      fontSize: _fontSize,
      color: colors.onSurface,
    );
    final inactiveStyle = AppSemanticTextStyles.pcLabel.copyWith(
      fontSize: _fontSize,
      fontWeight: FontWeight.w600,
      color: colors.textTertiary,
    );
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null || isActive ? null : () => onChanged!(opt),
        child: Container(
          padding: const EdgeInsets.all(_segmentPadding),
          decoration: BoxDecoration(
            color: isActive ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(_segmentRadius),
          ),
          child: Center(
            child: Text(
              opt,
              textAlign: TextAlign.center,
              style: isActive ? activeStyle : inactiveStyle,
            ),
          ),
        ),
      ),
    );
  }
}
