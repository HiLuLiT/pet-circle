import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class TogglePill extends StatelessWidget {
  const TogglePill({super.key, required this.isOn});

  final bool isOn;

  static const _duration = Duration(milliseconds: 250);
  static const _curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return AnimatedContainer(
      duration: _duration,
      curve: _curve,
      width: 75,
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isOn ? c.primary : c.disabled,
        borderRadius: AppRadiiTokens.borderRadiusFull,
      ),
      child: AnimatedAlign(
        duration: _duration,
        curve: _curve,
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 31,
          height: 31,
          decoration: const BoxDecoration(
            color: AppPrimitives.skyWhite,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
