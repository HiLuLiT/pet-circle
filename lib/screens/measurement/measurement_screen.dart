import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  int _selectedTab = 0;
  int _selectedDuration = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _Header(),
              const SizedBox(height: AppSpacing.lg),
              _TabSelector(
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _selectedTab == 0
                    ? _ManualMode(
                        selectedDuration: _selectedDuration,
                        onDurationChanged: (value) =>
                            setState(() => _selectedDuration = value),
                      )
                    : const _VisionMode(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.offWhite,
                  child: Text('P', style: TextStyle(color: AppColors.burgundy)),
                ),
                SizedBox(width: 8),
                Text('Princess', style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(
              width: 260,
              child: Text('Measure respiratory rate', style: AppTextStyles.heading2),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            RoundIconButton(
              icon: const Icon(Icons.language, color: AppColors.burgundy),
            ),
            const SizedBox(width: 8),
            RoundIconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.burgundy),
            ),
          ],
        ),
      ],
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Manual Mode',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabButton(
            label: 'VisionRR Mode',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.burgundy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualMode extends StatelessWidget {
  const _ManualMode({
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  final int selectedDuration;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeumorphicCard(
          padding: const EdgeInsets.all(24),
          radius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Timer Duration', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DurationButton(
                    label: '15s',
                    selected: selectedDuration == 15,
                    onTap: () => onDurationChanged(15),
                  ),
                  _DurationButton(
                    label: '30s',
                    selected: selectedDuration == 30,
                    onTap: () => onDurationChanged(30),
                  ),
                  _DurationButton(
                    label: '60s',
                    selected: selectedDuration == 60,
                    onTap: () => onDurationChanged(60),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: NeumorphicCard(
            padding: const EdgeInsets.all(32),
            radius: BorderRadius.circular(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('0', style: TextStyle(fontSize: 64, color: AppColors.burgundy)),
                  SizedBox(height: AppSpacing.sm),
                  Text('Tap to begin', style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationButton extends StatelessWidget {
  const _DurationButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected ? AppShadows.neumorphicInner : AppShadows.neumorphicOuter,
          ),
          child: Center(
            child: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _VisionMode extends StatelessWidget {
  const _VisionMode();

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(24),
      radius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('VisionRR Mode', style: AppTextStyles.heading3),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Use your camera to detect subtle chest motion while your pet sleeps. '
            'This mode is hands-free and designed for accurate SRR tracking.',
            style: AppTextStyles.body,
          ),
          SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Center(
              child: Icon(Icons.videocam, size: 64, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
