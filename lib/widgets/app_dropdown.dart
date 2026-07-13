import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// Pet Circle v3 (Claude-Design) select trigger.
///
/// Visual contract (from React `Select` component):
///   • Closed: white surface, no border, radius 12 (pcField), padding 16
///     all around (per Figma node 535-1158 — 16+24+16 = 56h). Selected
///     text: 16px bold, color = ink. Placeholder: 16px bold, color =
///     inkTertiary. Right side: expand_more / expand_less chevron tinted
///     inkSecondary.
///   • Open (when [isOpen] = true and [options] provided): a list of
///     options is rendered inline below the trigger (default) or as a
///     floating overlay on top of subsequent content ([overlayMode] = true).
///     Each option: padding 12×8, radius 4 (per Figma node 510-1220).
///     Selected option: bg = accentPurpleTile, text = regular-weight ink.
///     Unselected: transparent bg, regular-weight inkTertiary.
///
/// Public API is preserved from earlier revisions: `label`, `value`,
/// `onTap`, `isOpen`, `chevronController` are unchanged. New optional
/// `options` + `onOptionSelected` enable the open-list rendering
/// without breaking existing callers.
class AppDropdown extends StatefulWidget {
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
    this.overlayMode = false,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isOpen;
  final AnimationController? chevronController;

  /// Optional list of options. When provided together with [isOpen] = true,
  /// the widget renders an option list.
  final List<String>? options;

  /// Called when an option from [options] is selected. Required if
  /// [options] is provided and the caller wants tap handling.
  final ValueChanged<String>? onOptionSelected;

  /// Override placeholder text shown when [value] is null. Falls back to
  /// an empty string for backward compatibility.
  final String? placeholder;

  /// When true, the open option list is rendered in the root [Overlay] so it
  /// floats over content below the trigger rather than pushing it down.
  /// Use this when the dropdown sits above content that must not shift on open
  /// (e.g. a chart).
  final bool overlayMode;

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  // Key used to measure the trigger's position and width when inserting the
  // overlay entry.
  final _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void didUpdateWidget(covariant AppDropdown old) {
    super.didUpdateWidget(old);
    if (!widget.overlayMode) return;

    if (widget.isOpen && !old.isOpen) {
      // Schedule after frame so the trigger is fully laid out before we
      // measure its position.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _insertOverlay();
      });
    } else if (!widget.isOpen && old.isOpen) {
      _removeOverlay();
    } else if (widget.isOpen && _overlayEntry != null) {
      // Value changed while open — refresh the selected highlight.
      _overlayEntry!.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _insertOverlay() {
    _removeOverlay();

    final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final origin = box.localToGlobal(Offset.zero);
    final triggerSize = box.size;

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        // Resolve colors from the overlay context — the Overlay inherits the
        // MaterialApp theme so AppSemanticColors is always available.
        final c = AppSemanticColors.of(ctx);
        return Positioned(
          left: origin.dx,
          top: origin.dy + triggerSize.height + AppSpacingTokens.pcXs,
          width: triggerSize.width,
          child: Material(
            color: Colors.transparent,
            child: _OpenList(
              options: widget.options ?? [],
              selectedValue: widget.value,
              onSelected: widget.onOptionSelected,
              colors: c,
            ),
          ),
        );
      },
    );

    Overlay.of(_triggerKey.currentContext!).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);

    final labelWidgets = widget.label.isNotEmpty
        ? <Widget>[
            Text(widget.label, style: AppSemanticTextStyles.labelSm),
            const SizedBox(height: AppSpacingTokens.sm),
          ]
        : const <Widget>[];

    final trigger = _Trigger(
      value: widget.value,
      placeholder: widget.placeholder,
      isOpen: widget.isOpen,
      chevronController: widget.chevronController,
      onTap: widget.onTap,
      colors: c,
    );

    if (widget.overlayMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...labelWidgets,
          // Container gives _triggerKey a stable RenderBox to measure.
          Container(key: _triggerKey, child: trigger),
        ],
      );
    }

    // Default: inline list pushes content below the dropdown down.
    final hasOpenList =
        widget.isOpen && widget.options != null && widget.options!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...labelWidgets,
        trigger,
        if (hasOpenList) ...[
          const SizedBox(height: AppSpacingTokens.pcXs),
          _OpenList(
            options: widget.options!,
            selectedValue: widget.value,
            onSelected: widget.onOptionSelected,
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
        // 16px all around, no border — matches Figma "Input" component
        // (node 535-1158) exactly: 16+24(text line-height)+16 = 56h.
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadiiTokens.borderRadiusField,
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
    final bg = isSelected ? colors.accentPurpleTile : Colors.transparent;
    final style = AppSemanticTextStyles.pcBody.copyWith(
      color: isSelected ? colors.textPrimary : colors.textTertiary,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadiiTokens.borderRadiusSm,
        ),
        child: Text(label, style: style, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
