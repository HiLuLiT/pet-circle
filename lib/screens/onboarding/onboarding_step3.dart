import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_input_decoration.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';
import 'package:pet_circle/widgets/radio_card.dart';

class OnboardingStep3 extends StatefulWidget {
  const OnboardingStep3({super.key, this.onBack, this.onNext, this.nextLabel, this.onClose, this.onTargetRateChanged, this.initialTargetRate, this.isNextLoading = false});

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final VoidCallback? onClose;
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
      onClose: widget.onClose,
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
          RadioCard(
            title: l10n.normalRangeLabel,
            description: l10n.standardRateDescription,
            selected: _selected == '30',
            onTap: () {
              setState(() => _selected = '30');
              widget.onTargetRateChanged?.call(30);
            },
          ),
          const SizedBox(height: 12),
          RadioCard(
            title: l10n.elevatedRangeLabel,
            description: l10n.elevatedRateDescription,
            selected: _selected == '35',
            onTap: () {
              setState(() => _selected = '35');
              widget.onTargetRateChanged?.call(35);
            },
          ),
          const SizedBox(height: 12),
          RadioCard(
            title: l10n.customRate,
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
                      decoration: appInputDecoration(
                        context,
                        hintText: l10n.enterBpm,
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
