import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';

/// A 46x28 pill-shaped on/off switch widget.
///
/// Implements the PC v3 / Claude-Design palette toggle:
/// - On  : background = `AppSemanticColors.of(context).accentPurpleTile`
/// - Off : background = `#E8E4D8` (Butter/Cream, per Figma Toggle `465:3781`)
/// - Knob: 22x22 white circle, animated 200ms between `left: 3` and `left: 21`
/// - Disabled: wrapped in `Opacity(0.5)` and ignores taps
///
/// This is a *binary* switch — distinct from the segmented [TogglePill] widget
/// in `toggle_pill.dart`.
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.disabled = false,
  });

  /// Current on/off state.
  final bool value;

  /// Called with the *new* value (i.e. `!value`) when the user taps the toggle.
  /// Not invoked while [disabled] is true.
  final ValueChanged<bool>? onChanged;

  /// When true, the toggle is dimmed and does not respond to taps.
  final bool disabled;

  static const double _width = 46;
  static const double _height = 28;
  static const double _knobSize = 22;
  static const double _knobInset = 3;
  static const double _knobOnLeft = _width - _knobSize - _knobInset; // 21
  static const Color _offColor = Color(0xFFE8E4D8);
  static const Duration _duration = Duration(milliseconds: 200);
  static const Curve _curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final semanticColors = AppSemanticColors.of(context);
    final Color background = value ? semanticColors.accentPurpleTile : _offColor;

    final Widget pill = AnimatedContainer(
      duration: _duration,
      curve: _curve,
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: _duration,
            curve: _curve,
            top: _knobInset,
            left: value ? _knobOnLeft : _knobInset,
            child: Container(
              width: _knobSize,
              height: _knobSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );

    final Widget interactive = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => onChanged?.call(!value),
      child: pill,
    );

    if (disabled) {
      return Opacity(opacity: 0.5, child: interactive);
    }
    return interactive;
  }
}
