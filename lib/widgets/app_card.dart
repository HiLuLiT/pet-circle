import 'package:flutter/material.dart';

import '../theme/semantic/color_scheme.dart';
import '../theme/tokens/spacing.dart';

/// Variants for [AppCard].
///
/// - [surface]: a neutral white/surface-colored card.
/// - [tile]: a colored "tile" card (defaults to the purple accent tile).
enum AppCardVariant { surface, tile }

/// Flat, rounded card following the Pet Circle v3 / Claude-Design palette.
///
/// Replaces the legacy [NeumorphicCard] which used neumorphic shadows. The
/// new design system uses flat surfaces (no shadow) with rounded corners
/// (radius [AppRadiiTokens.pcCard], 18) and 16px padding by default.
///
/// Example:
/// ```dart
/// AppCard(
///   child: Text('Hello'),
/// )
///
/// AppCard(
///   variant: AppCardVariant.tile,
///   child: Text('On purple tile'),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.variant = AppCardVariant.surface,
    this.tileColor,
    this.padding,
    this.child,
  });

  /// Visual variant of the card.
  final AppCardVariant variant;

  /// Optional override for the [AppCardVariant.tile] background color.
  ///
  /// Ignored when [variant] is [AppCardVariant.surface]. When [variant] is
  /// [AppCardVariant.tile] and this is `null`, falls back to
  /// `AppSemanticColors.of(context).accentPurpleTile`.
  final Color? tileColor;

  /// Inner padding around [child]. Defaults to `EdgeInsets.all(16)`.
  final EdgeInsetsGeometry? padding;

  /// Card contents.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);
    final Color background = switch (variant) {
      AppCardVariant.surface => colors.surface,
      AppCardVariant.tile => tileColor ?? colors.accentPurpleTile,
    };

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
      ),
      child: child,
    );
  }
}
