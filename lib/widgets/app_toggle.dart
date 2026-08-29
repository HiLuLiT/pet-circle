import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/motion.dart';

/// A 46x28 pill-shaped on/off switch widget.
///
/// Implements the PC v3 / Claude-Design palette toggle:
/// - On  : background = `AppSemanticColors.of(context).accentPurpleTile`
/// - Off : background = `AppSemanticColors.of(context).accentButterCream`
///   (`#E8E4D8` Candy/Butter/Cream, per Figma Toggle `465:3781`)
/// - Knob: 22x22 white circle, spring-driven between `left: 3` and `left: 21`
///   (apple-design skill §4 — a critically-damped spring settles more
///   naturally than a fixed-duration ease, and animates from wherever the
///   knob currently is if toggled again mid-flight)
/// - Disabled: wrapped in `Opacity(0.5)` and ignores taps
///
/// This is a *binary* switch — distinct from the segmented [TogglePill] widget
/// in `toggle_pill.dart`.
class AppToggle extends StatefulWidget {
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
  static const Duration _colorDuration = Duration(milliseconds: 200);
  static const Curve _colorCurve = Curves.easeInOut;

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _knobController;

  double get _targetLeft =>
      widget.value ? AppToggle._knobOnLeft : AppToggle._knobInset;

  @override
  void initState() {
    super.initState();
    _knobController = AnimationController.unbounded(
      vsync: this,
      value: _targetLeft,
    );
  }

  @override
  void didUpdateWidget(covariant AppToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final target = _targetLeft;
      if (AppMotionTokens.reducedMotionOf(context)) {
        _knobController.value = target;
      } else {
        _knobController.animateWith(
          SpringSimulation(
            AppMotionTokens.spring(),
            _knobController.value,
            target,
            _knobController.velocity,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _knobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = AppSemanticColors.of(context);
    final Color background = widget.value
        ? semanticColors.accentPurpleTile
        : semanticColors.accentButterCream;

    final Widget pill = AnimatedContainer(
      duration: AppToggle._colorDuration,
      curve: AppToggle._colorCurve,
      width: AppToggle._width,
      height: AppToggle._height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _knobController,
            builder: (context, child) => Positioned(
              top: AppToggle._knobInset,
              left: _knobController.value,
              child: child!,
            ),
            child: Container(
              width: AppToggle._knobSize,
              height: AppToggle._knobSize,
              decoration: BoxDecoration(
                // Not `surface`: the knob must stay the lightest thing in the
                // control, and `surface` inverts to a dark card in dark mode.
                color: semanticColors.knobFill,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );

    final Widget interactive = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.disabled
          ? null
          : () => widget.onChanged?.call(!widget.value),
      child: pill,
    );

    if (widget.disabled) {
      return Opacity(opacity: 0.5, child: interactive);
    }
    return interactive;
  }
}
