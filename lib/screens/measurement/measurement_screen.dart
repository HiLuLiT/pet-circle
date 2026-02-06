import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_theme.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  int _selectedTab = 0;
  int _selectedDuration = 60;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _TabSelector(
              selectedIndex: _selectedTab,
              onChanged: (index) => setState(() => _selectedTab = index),
            ),
            const SizedBox(height: 32),
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
    );

    if (!widget.showScaffold) {
      return Container(color: AppColors.white, child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: content,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _TabButton(
            icon: Icons.touch_app,
            label: l10n.manualMode,
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabButton(
            icon: Icons.videocam_outlined,
            label: l10n.visionRRMode,
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
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 29,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: AppColors.burgundy),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.burgundy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualMode extends StatefulWidget {
  const _ManualMode({
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  final int selectedDuration;
  final ValueChanged<int> onDurationChanged;

  @override
  State<_ManualMode> createState() => _ManualModeState();
}

class _ManualModeState extends State<_ManualMode>
    with SingleTickerProviderStateMixin {
  bool _isRunning = false;
  int _remainingSeconds = 0;
  int _tapCount = 0;
  Timer? _timer;
  static const _lightBlue = Color(0xFF75ACFF);

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.selectedDuration;

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_ManualMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDuration != widget.selectedDuration && !_isRunning) {
      setState(() => _remainingSeconds = widget.selectedDuration);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _tapCount = 0;
      _remainingSeconds = widget.selectedDuration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    
    // Calculate BPM: (taps / duration) * 60
    final bpm = (_tapCount / widget.selectedDuration * 60).round();
    
    setState(() => _isRunning = false);

    final l10n = AppLocalizations.of(context)!;
    
    // Show result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.favorite, color: AppColors.pink),
            const SizedBox(width: 8),
            Text(l10n.measurementComplete),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$bpm',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: AppColors.burgundy,
              ),
            ),
            Text(l10n.breathsPerMinute, style: AppTextStyles.body),
            const SizedBox(height: 16),
            Text(
              l10n.breathCountMessage(_tapCount, widget.selectedDuration),
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _remainingSeconds = widget.selectedDuration);
            },
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  void _onTap() {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Scale animation: shrink then bounce back
    _scaleController.forward().then((_) => _scaleController.reverse());

    if (!_isRunning) {
      _startTimer();
    }

    setState(() => _tapCount++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = widget.selectedDuration == 0
        ? 0.0
        : (_remainingSeconds / widget.selectedDuration).clamp(0.0, 1.0);

    return Column(
      children: [
        // Timer Duration selector
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.timerDuration,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _DurationChip(
                    label: l10n.duration15s,
                    selected: widget.selectedDuration == 15,
                    onTap: _isRunning ? null : () => widget.onDurationChanged(15),
                  ),
                  const SizedBox(width: 16),
                  _DurationChip(
                    label: l10n.duration30s,
                    selected: widget.selectedDuration == 30,
                    onTap: _isRunning ? null : () => widget.onDurationChanged(30),
                  ),
                  const SizedBox(width: 16),
                  _DurationChip(
                    label: l10n.duration60s,
                    selected: widget.selectedDuration == 60,
                    onTap: _isRunning ? null : () => widget.onDurationChanged(60),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                '${_remainingSeconds}s',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w500,
                  color: AppColors.burgundy,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.burgundy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 8,
                        width: width * progress,
                        decoration: BoxDecoration(
                          color: _lightBlue,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _onTap,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                  child: Container(
                    width: 206,
                    height: 206,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_tapCount',
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w500,
                            color: AppColors.burgundy,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRunning ? l10n.tapToStop : l10n.tapToBegin,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF75ACFF) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.burgundy,
            ),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.visionRRMode, style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.visionRRModeDescription,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Expanded(
            child: Center(
              child: Icon(Icons.videocam, size: 64, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
