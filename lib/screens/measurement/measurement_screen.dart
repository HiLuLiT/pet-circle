import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.pink.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.pink,
                      child: Text('P',
                          style:
                              TextStyle(color: AppColors.burgundy, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Princess', style: AppTextStyles.body),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            RoundIconButton(
              icon: const Icon(Icons.language, color: AppColors.burgundy, size: 20),
            ),
            const SizedBox(width: 8),
            RoundIconButton(
              icon: const Icon(Icons.notifications_none,
                  color: AppColors.burgundy, size: 20),
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
            icon: Icons.touch_app,
            label: 'Manual Mode',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabButton(
            icon: Icons.videocam_outlined,
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? AppColors.warningAmber : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.burgundy : AppColors.textMuted,
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
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.selectedDuration;
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
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
    _timer?.cancel();
    _pulseController.dispose();
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
    
    // Show result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.favorite, color: AppColors.pink),
            SizedBox(width: 8),
            Text('Measurement Complete'),
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
            const Text('breaths per minute', style: AppTextStyles.body),
            const SizedBox(height: 16),
            Text(
              'You counted $_tapCount breaths in ${widget.selectedDuration} seconds.',
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
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _onTap() {
    if (!_isRunning) {
      _startTimer();
    }
    
    setState(() => _tapCount++);
    
    // Pulse animation
    _pulseController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _isRunning
        ? 1 - (_remainingSeconds / widget.selectedDuration)
        : 0.0;

    return Column(
      children: [
        // Timer Duration selector
        NeumorphicCard(
          padding: const EdgeInsets.all(20),
          radius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Timer Duration', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _DurationChip(
                    label: '15s',
                    selected: widget.selectedDuration == 15,
                    onTap: _isRunning ? null : () => widget.onDurationChanged(15),
                  ),
                  const SizedBox(width: 12),
                  _DurationChip(
                    label: '30s',
                    selected: widget.selectedDuration == 30,
                    onTap: _isRunning ? null : () => widget.onDurationChanged(30),
                  ),
                  const SizedBox(width: 12),
                  _DurationChip(
                    label: '60s',
                    selected: widget.selectedDuration == 60,
                    onTap: _isRunning ? null : () => widget.onDurationChanged(60),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Timer display
        Text(
          '${_remainingSeconds}s',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: AppColors.warningAmber.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Circular tap area
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: _onTap,
              child: NeumorphicCard(
                radius: BorderRadius.circular(1000),
                padding: EdgeInsets.zero,
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress ring
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CustomPaint(
                          painter: _CircularProgressPainter(
                            progress: progress,
                            strokeWidth: 8,
                            backgroundColor: AppColors.offWhite,
                            progressColor: AppColors.warningAmber,
                          ),
                        ),
                      ),
                      // Inner circle with count
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = 1.0 +
                              (0.05 *
                                  math.sin(_pulseController.value * math.pi));
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
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
                                  fontSize: 56,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.burgundy,
                                ),
                              ),
                              Text(
                                _isRunning ? 'Tap for each breath' : 'Tap to begin',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isRunning) ...[
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: _stopTimer,
            child: Text(
              'Stop & Calculate',
              style: AppTextStyles.body.copyWith(color: AppColors.burgundy),
            ),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.burgundy : AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.burgundy : AppColors.offWhite,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2, // Start from top
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
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
