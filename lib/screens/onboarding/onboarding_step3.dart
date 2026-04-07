import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep3 extends StatefulWidget {
  const OnboardingStep3({super.key, this.onBack, this.onNext, this.nextLabel, this.onTargetRateChanged, this.initialTargetRate, this.isNextLoading = false});

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final ValueChanged<int>? onTargetRateChanged;
  final int? initialTargetRate;
  final bool isNextLoading;

  @override
  State<OnboardingStep3> createState() => _OnboardingStep3State();
}

class _OnboardingStep3State extends State<OnboardingStep3> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late String _selected;
  final _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final rate = widget.initialTargetRate ?? 30;
    if (rate == 30) {
      _selected = '30';
    } else if (rate == 35) {
      _selected = '35';
    } else {
      _selected = 'custom';
      _customController.text = '$rate';
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    return OnboardingShell(
      title: l10n.setupPetProfile,
      stepLabel: l10n.onboardingStep(3, 3),
      progress: 1,
      onBack: widget.onBack,
      onNext: widget.onNext,
      nextLabel: widget.nextLabel,
      isNextLoading: widget.isNextLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.targetRespiratoryRate, style: AppSemanticTextStyles.headingLg),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.targetRateDescription,
            style: AppSemanticTextStyles.body,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          _TargetOption(
            title: l10n.normalRangeLabel,
            subtitle: l10n.standardRateDescription,
            selected: _selected == '30',
            onTap: () {
              setState(() => _selected = '30');
              widget.onTargetRateChanged?.call(30);
            },
          ),
          const SizedBox(height: 12),
          _TargetOption(
            title: l10n.elevatedRangeLabel,
            subtitle: l10n.elevatedRateDescription,
            selected: _selected == '35',
            onTap: () {
              setState(() => _selected = '35');
              widget.onTargetRateChanged?.call(35);
            },
          ),
          const SizedBox(height: 12),
          _TargetOption(
            title: l10n.customRate,
            subtitle: null,
            selected: _selected == 'custom',
            onTap: () => setState(() => _selected = 'custom'),
          ),
          // Custom rate input field
          if (_selected == 'custom')
            Padding(
              padding: const EdgeInsets.only(top: AppSpacingTokens.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      onChanged: (value) {
                        final rate = int.tryParse(value);
                        if (rate != null) widget.onTargetRateChanged?.call(rate);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: c.background,
                        hintText: l10n.enterBpm,
                        hintStyle: AppSemanticTextStyles.body
                            .copyWith(color: c.textTertiary),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadiiTokens.borderRadiusLg,
                          borderSide: BorderSide(color: c.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadiiTokens.borderRadiusLg,
                          borderSide: BorderSide(color: c.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacingTokens.md,
                          vertical: 14,
                        ),
                      ),
                      style: AppSemanticTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Text(
                    l10n.bpm,
                    style: AppSemanticTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TargetOption extends StatelessWidget {
  const _TargetOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadiiTokens.borderRadiusLg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: selected ? c.primaryLightest : c.surface,
          borderRadius: AppRadiiTokens.borderRadiusLg,
          border: Border.all(
            color: selected ? c.primary : c.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? c.primary : c.surface,
                border: Border.all(
                  color: selected ? c.primary : c.divider,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppSemanticTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacingTokens.xs),
                    Text(
                      subtitle!,
                      style: AppSemanticTextStyles.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
