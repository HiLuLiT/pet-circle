import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';

/// Displays a user avatar. Shows network image if [imageUrl] is non-empty and
/// starts with 'http'. Otherwise falls back to initials derived from [name].
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 36,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  /// Overrides the default fallback background color (`c.primaryLight`) when
  /// provided.
  final Color? backgroundColor;

  /// Overrides the default initials text color (`c.textPrimary`) when
  /// provided.
  final Color? foregroundColor;

  /// Overrides the initials text style. Figma sizes initials per context
  /// rather than proportionally — the 32px header avatar uses Label/S Bold
  /// 13/18 (node 442:6750) while the 28px care-circle avatars use Caption/XS
  /// 10/14 (node 442:8952). Defaults to the proportional fallback.
  final TextStyle? textStyle;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get _hasNetworkImage =>
      imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http');

  /// Initials style: an explicit [textStyle] when given (recolored to the
  /// avatar's foreground), otherwise the proportional fallback.
  TextStyle _initialsStyle(AppSemanticColors c) {
    final color = foregroundColor ?? c.textPrimary;
    final override = textStyle;
    if (override != null) return override.copyWith(color: color);
    return AppSemanticTextStyles.labelSm.copyWith(
      color: color,
      fontSize: size * 0.38,
      height: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.surface, width: 2),
          color: _hasNetworkImage ? null : (backgroundColor ?? c.primaryLight),
        ),
        child: ClipOval(
          child: _hasNetworkImage
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (_, __, ___) =>
                      Center(child: Text(_initials, style: _initialsStyle(c))),
                )
              : Center(child: Text(_initials, style: _initialsStyle(c))),
        ),
      ),
    );
  }
}
