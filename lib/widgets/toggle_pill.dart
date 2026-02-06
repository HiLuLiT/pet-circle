import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TogglePill extends StatelessWidget {
  const TogglePill({super.key, required this.isOn});

  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Container(
      width: 75,
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isOn ? c.chocolate : c.chocolate.withOpacity(0.2),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Align(
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: c.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
