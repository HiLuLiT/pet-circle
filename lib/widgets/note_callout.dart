import 'package:flutter/material.dart';

import '../theme/semantic/color_scheme.dart';
import '../theme/semantic/text_theme.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';

/// Informational "note" callout following the Pet Circle v3 / Claude-Design
/// palette.
///
/// Matches the Figma "note" content card (node 442:8369): a warm cream tile
/// with a leading info icon and bold title on the header row, followed by a
/// secondary-colored body paragraph.
///
/// Spec mapping:
/// - Background `Candy/Butter/Cream` (#E8E4D8) → semantic token
///   [AppSemanticColors.accentButterCream]. The bright `accentButterTile`
///   token is yellow and intentionally not used.
/// - Radius 12 → [AppRadiiTokens.borderRadiusField] sentinel is 14; the spec
///   value 12 is honoured directly via [BorderRadius.circular].
/// - Padding 16 → [EdgeInsets.all] (16).
/// - Title `Label/L Bold` (15/20 bold) → closest semantic [AppSemanticTextStyles.pcLabelBold]
///   (14/20 bold, ink) — the PC v3 scale has no 15px size.
/// - Body `Label/M Regular` (14/20 regular, Neutrals/Secondary) →
///   [AppSemanticTextStyles.pcLabelMuted] (14/20 regular, textSecondary).
///
/// Example:
/// ```dart
/// NoteCallout(
///   title: l10n.note,
///   body: l10n.diagnosisNote,
/// )
/// ```
class NoteCallout extends StatelessWidget {
  const NoteCallout({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.info_outline,
  });

  /// Bold header title (e.g. "Note:").
  final String title;

  /// Body paragraph describing the note.
  final String body;

  /// Leading header icon. Defaults to [Icons.info_outline].
  final IconData icon;

  /// Spec radius (12) — honoured directly as the PC v3 scale has no 12 token.
  static const double _radius = 12;

  /// Spec icon size (24).
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: colors.accentButterCream,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: _iconSize,
                // Fixed dark ink to match the title/body on the always-cream
                // tile; theme-adaptive onSurface would be illegible in dark.
                color: AppPrimitives.pcInk,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppSemanticTextStyles.pcLabelBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          Text(
            body,
            style: AppSemanticTextStyles.pcLabelMuted,
          ),
        ],
      ),
    );
  }
}
