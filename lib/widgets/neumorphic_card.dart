import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/shadows.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class NeumorphicCard extends StatelessWidget {
  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.radius,
    this.inner = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? radius;
  final bool inner;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    // PC v3 card radius (18). Callers may still override via [radius].
    final cardRadius = radius ?? AppRadiiTokens.borderRadiusCard;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        // Inner (recessed/inset) cards sit on a recessed surface and cast no
        // drop shadow; raised cards use the small elevation shadow.
        color: color ?? (inner ? c.surfaceRecessed : c.surface),
        borderRadius: cardRadius,
        boxShadow: inner ? const [] : AppShadowTokens.small,
      ),
      child: child,
    );
  }
}
