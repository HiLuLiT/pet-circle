import 'package:flutter/material.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';

/// Horizontal alignment of the overlapping avatars within the stack.
enum AvatarStackAlignment { left, right }

/// A row of overlapping circular member avatars.
///
/// Shared between the owner and care-circle dashboards. The two contexts
/// differ in sizing, overlap, alignment and whether the leading avatar is
/// highlighted, so those are exposed as parameters.
///
/// Each avatar shows the member's network image when available, falling back
/// to a neutral initials circle when the URL is empty/invalid or the image
/// fails to load (see [_AvatarCircle]).
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.avatars,
    this.avatarSize = 24,
    this.overlap = 8,
    this.alignment = AvatarStackAlignment.right,
    this.borderColor,
    this.highlightFirst = false,
    this.highlightBorderColor,
  });

  /// Members to render, in display order.
  final List<CareCircleMember> avatars;

  /// Diameter of each avatar circle.
  final double avatarSize;

  /// How many logical pixels adjacent avatars overlap.
  final double overlap;

  /// Whether avatars are laid out from the left or the right edge.
  final AvatarStackAlignment alignment;

  /// Border colour applied to every avatar. Defaults to [AppSemanticColors.surface].
  final Color? borderColor;

  /// When true, the leading avatar gets [highlightBorderColor] and a subtle
  /// glow to mark it (e.g. the active member).
  final bool highlightFirst;

  /// Border colour for the leading avatar when [highlightFirst] is true.
  /// Defaults to [AppSemanticColors.primaryLight].
  final Color? highlightBorderColor;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final count = avatars.length;
    if (count == 0) return const SizedBox.shrink();

    final step = avatarSize - overlap;
    final resolvedBorder = borderColor ?? c.surface;
    final resolvedHighlight = highlightBorderColor ?? c.primaryLight;
    // Trailing breathing room so the (clipped) glow / border is not cut off.
    const double edgePad = 8;

    return SizedBox(
      height: avatarSize,
      width: avatarSize + (count - 1) * step + edgePad,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              left: alignment == AvatarStackAlignment.left
                  ? i * step
                  : null,
              right: alignment == AvatarStackAlignment.right
                  ? edgePad + i * step
                  : null,
              child: _AvatarCircle(
                member: avatars[i],
                size: avatarSize,
                borderColor: highlightFirst && i == 0
                    ? resolvedHighlight
                    : resolvedBorder,
                glow: highlightFirst && i == 0 ? resolvedHighlight : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// A single avatar circle. Renders the member's network image, falling back to
/// initials on an [AppSemanticColors.surfaceRecessed] circle when the URL is
/// empty/invalid or the image fails to load.
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.member,
    required this.size,
    required this.borderColor,
    this.glow,
  });

  final CareCircleMember member;
  final double size;
  final Color borderColor;

  /// Optional glow colour drawn behind the circle.
  final Color? glow;

  String get _initials {
    final parts = member.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get _hasNetworkImage => member.avatarUrl.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final fallback = _Initials(text: _initials, size: size);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        // Recessed surface shows through behind the initials fallback.
        color: _hasNetworkImage ? null : c.surfaceRecessed,
        boxShadow: glow != null
            ? [BoxShadow(color: glow!.withValues(alpha: 0.3), blurRadius: 0)]
            : null,
      ),
      child: ClipOval(
        child: _hasNetworkImage
            ? Image.network(
                member.avatarUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (context, error, stackTrace) => fallback,
              )
            : fallback,
      ),
    );
  }
}

/// Neutral initials fallback shown on a recessed circle.
class _Initials extends StatelessWidget {
  const _Initials({required this.text, required this.size});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      color: c.surfaceRecessed,
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppSemanticTextStyles.labelSm.copyWith(
          color: c.textSecondary,
          fontSize: size * 0.38,
          height: 1,
        ),
      ),
    );
  }
}
