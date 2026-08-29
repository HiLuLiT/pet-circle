import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/motion.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// Segmented two-option pill. The knob's horizontal position is
/// spring-driven (apple-design skill §4) rather than eased on a fixed
/// duration, so it settles naturally and stays continuous if [isOn] flips
/// again before the previous transition finishes.
class TogglePill extends StatefulWidget {
  const TogglePill({super.key, required this.isOn});

  final bool isOn;

  static const _colorDuration = Duration(milliseconds: 250);
  static const _colorCurve = Curves.easeInOut;

  @override
  State<TogglePill> createState() => _TogglePillState();
}

class _TogglePillState extends State<TogglePill>
    with SingleTickerProviderStateMixin {
  // Alignment.x ranges -1 (left) to 1 (right), so the spring can drive it
  // directly with no intermediate lerp-factor mapping.
  static const double _alignLeft = -1;
  static const double _alignRight = 1;

  late final AnimationController _knobController;

  double get _targetAlignX => widget.isOn ? _alignRight : _alignLeft;

  @override
  void initState() {
    super.initState();
    _knobController = AnimationController.unbounded(
      vsync: this,
      value: _targetAlignX,
    );
  }

  @override
  void didUpdateWidget(covariant TogglePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOn != widget.isOn) {
      final target = _targetAlignX;
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
    final c = AppSemanticColors.of(context);
    return AnimatedContainer(
      duration: TogglePill._colorDuration,
      curve: TogglePill._colorCurve,
      width: 75,
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: widget.isOn ? c.primary : c.disabled,
        borderRadius: AppRadiiTokens.borderRadiusFull,
      ),
      child: AnimatedBuilder(
        animation: _knobController,
        builder: (context, child) => Align(
          alignment: Alignment(_knobController.value, 0),
          child: child,
        ),
        child: Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
