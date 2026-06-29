import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// Pet Circle v3 (Claude-Design) select trigger.
///
/// Visual contract (from React `Select` component):
///   • Closed: white surface, radius 14 (pcField), padding 15×16.
///     Selected text: 16px bold, color = ink. Placeholder: 16px bold,
///     color = inkTertiary. Right side: expand_more / expand_less chevron
///     tinted inkSecondary.
///   • Open (when [isOpen] = true and [options] provided): a list of
///     options is rendered below the trigger, separated by a 1px hairline.
///     Each option: padding 12×14, radius 11. Selected option:
///     bg = accentPeriwinkleChip, text = bold ink. Unselected: transparent
///     bg, medium-weight inkSecondary.
///
/// Public API is preserved from earlier revisions: `label`, `value`,
/// `onTap`, `isOpen`, `chevronController` are unchanged. New optional
/// `options` + `onOptionSelected` enable the inline open-list rendering
/// without breaking existing callers.
class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.isOpen = false,
    this.chevronController,
    this.options,
    this.onOptionSelected,
    this.placeholder,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isOpen;
  final AnimationController? chevronController;

  /// Optional list of options. When provided together with [isOpen] = true,
  /// the widget renders an inline option list below the trigger.
  final List<String>? options;

  /// Called when an option from [options] is selected. Required if
  /// [options] is provided and the caller wants tap handling.
  final ValueChanged<String>? onOptionSelected;

  /// Override placeholder text shown when [value] is null. Falls back to
  /// an empty string for backward compatibility.
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Omit the label row entirely when no label is given, so callers that
        // pass an empty string (e.g. an inline picker) don't get a dead 8px gap.
        if (label.isNotEmpty) ...[
          Text(label, style: AppSemanticTextStyles.labelSm),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        _Trigger(
          value: value,
          placeholder: placeholder,
          isOpen: isOpen,
          chevronController: chevronController,
          onTap: onTap,
          colors: c,
        ),
        if (isOpen && options != null && options!.isNotEmpty) ...[
          const SizedBox(height: AppSpacingTokens.pcXs),
          _OpenList(
            options: options!,
            selectedValue: value,
            onSelected: onOptionSelected,
            colors: c,
          ),
        ],
      ],
    );
  }
}

class _Trigger extends StatelessWidget {
  const _Trigger({
    required this.value,
    required this.placeholder,
    required this.isOpen,
    required this.chevronController,
    required this.onTap,
    required this.colors,
  });

  final String? value;
  final String? placeholder;
  final bool isOpen;
  final AnimationController? chevronController;
  final VoidCallback onTap;
  final AppSemanticColors colors;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final displayText = hasValue ? value! : (placeholder ?? '');
    final textStyle = AppSemanticTextStyles.pcBodyBold.copyWith(
      color: hasValue ? colors.onSurface : colors.textTertiary,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadiiTokens.borderRadiusField,
          border: Border.all(color: colors.hairline, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                displayText,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _Chevron(
              isOpen: isOpen,
              controller: chevronController,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({
    required this.isOpen,
    required this.controller,
    required this.color,
  });

  final bool isOpen;
  final AnimationController? controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Use Icons.keyboard_arrow_down to remain compatible with existing tests
    // (and assets). When a [controller] is supplied we still animate via
    // RotationTransition; otherwise we swap the icon based on [isOpen].
    if (controller != null) {
      return RotationTransition(
        turns: Tween(begin: 0.0, end: 0.5).animate(
          CurvedAnimation(parent: controller!, curve: Curves.easeInOut),
        ),
        child: Icon(Icons.keyboard_arrow_down, color: color, size: 20),
      );
    }
    return Icon(
      isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      color: color,
      size: 20,
    );
  }
}

class _OpenList extends StatelessWidget {
  const _OpenList({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    required this.colors,
  });

  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String>? onSelected;
  final AppSemanticColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadiiTokens.borderRadiusField,
        border: Border.all(color: colors.hairline, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _Option(
              label: option,
              isSelected: option == selectedValue,
              onTap: onSelected == null ? null : () => onSelected!(option),
              colors: colors,
            ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final AppSemanticColors colors;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? colors.accentPeriwinkleChip : Colors.transparent;
    final style = isSelected
        ? AppSemanticTextStyles.pcBodyBold.copyWith(color: colors.onSurface)
        : AppSemanticTextStyles.pcBodyMedium.copyWith(
            color: colors.textSecondary,
          );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(label, style: style, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
