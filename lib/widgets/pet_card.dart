import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/status_badge.dart';

/// Size variant for [PetCard].
///
/// * [compact] — the default 24px `title3` name style used by all existing
///   dashboards (owner, vet, care-circle).
/// * [hero] — the larger 28px `pcDisplay` name style used by the new home
///   hero pet card (Figma node 402-1978).
enum PetCardSize { hero, compact }

/// Shared pet card — Figma "Pet Card" (node 442:8872).
///
/// A purple-tile card used across the owner, vet and care-circle dashboards.
/// The base layout matches the Figma design:
///
/// ```
/// ┌──────────────────────────────┐
/// │ [status pill]                 │   ← top-left StatusBadge
/// │                               │
/// │ Name              [ media ]   │   ← name + subtitle (left),
/// │ subtitle line     [ 90×90 ]   │     mascot / photo (right)
/// └──────────────────────────────┘
/// ```
///
/// The card is intentionally context-agnostic. Dashboard-specific extras
/// (owner avatar stack, vet "view only" badge, action buttons, etc.) are
/// supplied by callers through the [footer] and [trailing] slots rather than
/// baked into this widget.
///
/// Design-token choices (documented because the raw Figma values fall between
/// tokens):
///   * Card radius — Figma node is `20`; the nearest semantic radius token is
///     [AppRadiiTokens.pcCard] (`16`), which is far closer than
///     [AppRadiiTokens.pcTile] (`30`). We use `pcCard`.
///   * Padding — Figma node is `16`; matched exactly with
///     [AppSpacingTokens.md] (`16`).
///   * Name — Figma "Display/M" is `28px bold`; the default [PetCardSize.compact]
///     uses the nearest semantic style [AppSemanticTextStyles.title3]
///     (`24px bold`). Pass [PetCardSize.hero] to use the exact
///     [AppSemanticTextStyles.pcDisplay] (`28px bold`) match instead.
///   * Subtitle — Figma "Label/M Regular" (`14px`) maps cleanly to
///     [AppSemanticTextStyles.pcLabelMuted].
class PetCard extends StatelessWidget {
  const PetCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.status,
    required this.statusLabel,
    required this.media,
    this.onTap,
    this.onLongPress,
    this.footer,
    this.trailing,
    this.size = PetCardSize.compact,
  });

  /// Pet name — rendered as the card's bold heading.
  final String name;

  /// Subtitle line beneath the name (e.g. "Breed · SPR 31 bpm").
  final String subtitle;

  /// Status family driving the [StatusBadge] colors.
  final StatusBadgeStatus status;

  /// Localized status label shown inside the [StatusBadge].
  final String statusLabel;

  /// Right-aligned media slot — typically a [Mascot] or a [DogPhoto]. Rendered
  /// inside a fixed 90×90 box to match the Figma frame.
  final Widget media;

  /// Tap handler — usually navigates to the pet detail / shell tab.
  final VoidCallback? onTap;

  /// Long-press handler — e.g. the owner's "delete pet" confirmation.
  final VoidCallback? onLongPress;

  /// Optional content rendered full-width below the name/media row. Used by
  /// the owner dashboard for the care-circle avatar stack and action buttons.
  final Widget? footer;

  /// Optional overlay anchored to the top-right of the card. Used by the vet
  /// dashboard for the "view only" badge.
  final Widget? trailing;

  /// Size variant — [PetCardSize.compact] (default) preserves the existing
  /// 24px name style for all current callers; [PetCardSize.hero] uses the
  /// larger 28px `pcDisplay` style for the new home hero card.
  final PetCardSize size;

  /// Fixed size of the [media] slot — matches the Figma frame (`90×90`).
  static const double _mediaSize = 90;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);

    final card = Container(
      decoration: BoxDecoration(
        color: c.accentPurpleTile,
        borderRadius: AppRadiiTokens.borderRadiusCard,
      ),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top-left status pill.
          StatusBadge(label: statusLabel, status: status),
          const SizedBox(height: AppSpacingTokens.lg),
          // Name + subtitle (left), media (right).
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: (size == PetCardSize.hero
                              ? AppSemanticTextStyles.pcDisplay
                              : AppSemanticTextStyles.title3)
                          .copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: AppSpacingTokens.xs),
                    Text(
                      subtitle,
                      style: AppSemanticTextStyles.pcLabelMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              SizedBox(
                width: _mediaSize,
                height: _mediaSize,
                child: Center(child: media),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacingTokens.lg),
            SizedBox(width: double.infinity, child: footer),
          ],
        ],
      ),
    );

    final content = trailing == null
        ? card
        : Stack(
            children: [
              card,
              Positioned(
                top: AppSpacingTokens.md,
                right: AppSpacingTokens.md,
                child: trailing!,
              ),
            ],
          );

    if (onTap == null && onLongPress == null) return content;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: content,
    );
  }
}
