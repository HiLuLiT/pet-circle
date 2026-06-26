import 'package:flutter/material.dart';

import '../theme/semantic/color_scheme.dart';
import '../theme/semantic/text_theme.dart';
import '../theme/tokens/spacing.dart';

/// A notification list item card for the Pet Circle v3 (Claude-Design) palette.
///
/// Mirrors the React `NotificationCard` from `figma-code-connect/NotificationCard.tsx`:
/// - 18px rounded corners, 16px inset padding
/// - 44×44 circular icon tile on the left (caller supplies tile color and icon widget)
/// - Title (15.5px bold) row with an optional 9×9 purple "unread" dot at the trailing edge
/// - Body (13.5px regular) with 4px top spacing
/// - Time stamp (12.5px regular) with 8px top spacing
///
/// Read/unread variants:
/// - **unread**: surface bg, full-opacity tile, ink title, secondary body
/// - **read**: warm recessed bg (#EFEADF), 55%-opacity tile, muted gray title, tertiary body
///
/// Optional [onTap] makes the whole card a tappable target via [InkWell].
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.icon,
    required this.iconTileColor,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    this.onTap,
  });

  /// Pre-styled icon widget. Caller controls icon color/size — this widget
  /// only provides the surrounding 44×44 circular tile.
  final Widget icon;

  /// Background color of the round 44px tile. When the card is in the read
  /// state, this color is rendered at 55% opacity.
  final Color iconTileColor;

  final String title;
  final String body;
  final String time;

  /// When true, render the "unread" visual treatment (white surface, full
  /// tile opacity, ink title, trailing purple dot).
  final bool unread;

  /// Optional tap handler. When provided, the card becomes tappable.
  final VoidCallback? onTap;

  // Warm recessed bg used for the "read" state. Slightly warmer than the
  // global `pcRecessed` token to match the React source 1:1.
  static const Color _readBg = Color(0xFFEFEADF);

  // Muted title color for the "read" state (per React source).
  static const Color _readTitleColor = Color(0xFF6E6E6E);

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);
    final backgroundColor = unread ? colors.surface : _readBg;
    final tileColor =
        unread ? iconTileColor : iconTileColor.withValues(alpha: 0.55);

    final titleStyle = AppSemanticTextStyles.pcBodyBold.copyWith(
      fontSize: 15.5,
      color: unread ? colors.onSurface : _readTitleColor,
    );
    final bodyStyle = AppSemanticTextStyles.pcLabelMuted.copyWith(
      fontSize: 13.5,
      height: 1.5,
      color: unread ? colors.textSecondary : colors.textTertiary,
    );
    final timeStyle = AppSemanticTextStyles.pcCaptionMuted.copyWith(
      fontSize: 12.5,
      color: colors.textTertiary,
    );

    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconTile(color: tileColor, child: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: titleStyle,
                      ),
                    ),
                    if (unread) ...[
                      const SizedBox(width: 8),
                      _UnreadDot(color: colors.accentPurple),
                    ],
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(body, style: bodyStyle),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(time, style: timeStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Center(child: child),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('notification_card.unread_dot'),
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
