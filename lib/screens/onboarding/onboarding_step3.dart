import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return OnboardingShell(
      title: 'Setup pet profile',
      stepLabel: 'Step 3 of 4',
      progress: 0.75,
      onBack: widget.onBack,
      onNext: widget.onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Set Target Respiratory Rate', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            "We'll alert you when measurements exceed this threshold.",
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          _TargetOption(
            title: '30 BPM (Standard)',
            subtitle: 'Recommended for most dogs',
            selected: _selected == '30',
            trailingLabel: 'Most popular',
            onTap: () => setState(() => _selected = '30'),
          ),
          const SizedBox(height: 12),
          _TargetOption(
            title: '35 BPM',
            subtitle: 'For pets with mild conditions',
            selected: _selected == '35',
            onTap: () => setState(() => _selected = '35'),
          ),
          const SizedBox(height: 12),
          _TargetOption(
            title: 'Custom Rate',
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
                          hintText: 'Enter BPM',
                          hintStyle: AppTextStyles.body
                              .copyWith(color: AppColors.textMuted),
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
                      'BPM',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.burgundy,
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
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
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
                          color: Color(0xFF146FD9),
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
                          AppTextStyles.caption.copyWith(color: AppColors.burgundy),
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
                  style: AppTextStyles.caption.copyWith(color: AppColors.burgundy),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
