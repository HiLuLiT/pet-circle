import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep3 extends StatefulWidget {
  const OnboardingStep3({super.key, this.onBack, this.onNext, this.nextLabel, this.onTargetRateChanged, this.initialTargetRate});

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final ValueChanged<int>? onTargetRateChanged;
  final int? initialTargetRate;

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
      stepLabel: l10n.onboardingStep(3, 4),
      progress: 0.75,
      onBack: widget.onBack,
      onNext: widget.onNext,
      nextLabel: widget.nextLabel,
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
              child: Container(
                padding: const EdgeInsets.all(AppSpacingTokens.md),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: AppRadiiTokens.borderRadiusSm,
                ),
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
                          fillColor: c.warning.withValues(alpha: 0.2),
                          hintText: l10n.enterBpm,
                          hintStyle: AppSemanticTextStyles.body
                              .copyWith(color: c.textTertiary),
                          border: OutlineInputBorder(
                            borderRadius: AppRadiiTokens.borderRadiusLg,
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacingTokens.md,
                            vertical: 14,
                          ),
                        ),
                        style: AppSemanticTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
      borderRadius: AppRadiiTokens.borderRadiusSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: AppSpacingTokens.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: AppRadiiTokens.borderRadiusSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surface,
                boxShadow: [
                  BoxShadow(
                    color: c.onSurface.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: c.info,
                          shape: BoxShape.circle,
                        ),
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
                    style:
                        AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacingTokens.xs),
                    Text(
                      subtitle!,
                      style:
                          AppSemanticTextStyles.caption.copyWith(color: c.textSecondary),
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
