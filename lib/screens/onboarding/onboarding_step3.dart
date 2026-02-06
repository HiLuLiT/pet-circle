import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep3 extends StatefulWidget {
  const OnboardingStep3({super.key, this.onBack, this.onNext});

  final VoidCallback? onBack;
  final VoidCallback? onNext;

  @override
  State<OnboardingStep3> createState() => _OnboardingStep3State();
}

class _OnboardingStep3State extends State<OnboardingStep3> {
  String _selected = '30';
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OnboardingShell(
      title: l10n.setupPetProfile,
      stepLabel: l10n.onboardingStep(3, 4),
      progress: 0.75,
      onBack: widget.onBack,
      onNext: widget.onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.targetRespiratoryRate, style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.targetRateDescription,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          _TargetOption(
            title: l10n.normalRangeLabel,
            subtitle: l10n.standardRateDescription,
            selected: _selected == '30',
            onTap: () => setState(() => _selected = '30'),
          ),
          const SizedBox(height: 12),
          _TargetOption(
            title: l10n.elevatedRangeLabel,
            subtitle: l10n.elevatedRateDescription,
            selected: _selected == '35',
            onTap: () => setState(() => _selected = '35'),
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
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
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
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.lightYellow,
                          hintText: l10n.enterBpm,
                          hintStyle: AppTextStyles.body
                              .copyWith(color: AppColors.chocolate),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.bpm,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.chocolate,
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
    this.trailingLabel,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final String? trailingLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.chocolate),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.lightYellow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trailingLabel!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.chocolate),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
