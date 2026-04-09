import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/utils/responsive_utils.dart';

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
    return ListenableBuilder(
      listenable: Listenable.merge([petStore, userStore]),
      builder: (context, _) {
        final c = AppSemanticColors.of(context);
        final l10n = AppLocalizations.of(context)!;
        final access = petStore.accessForActivePet();

        if (!access.canMeasure) {
          final noPermissionContent = Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 48, color: c.textPrimary.withValues(alpha: 0.3)),
                  const SizedBox(height: AppSpacingTokens.md),
                  Text(
                    l10n.viewer,
                    style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    l10n.viewerMeasurementRestriction,
                    style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );

          if (!widget.showScaffold) {
            return Container(color: c.surface, child: noPermissionContent);
          }
          return Scaffold(backgroundColor: c.surface, body: noPermissionContent);
        }

        final content = SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsiveMaxWidth(context)),
                child: Column(
              children: [
                _TabSelector(
                  selectedIndex: _selectedTab,
                  onChanged: (index) => setState(() => _selectedTab = index),
                ),
                const SizedBox(height: AppSpacingTokens.xl),
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
          ),
        );

        if (!widget.showScaffold) {
          return Container(color: c.surface, child: content);
        }

        return Scaffold(
          backgroundColor: c.surface,
          body: content,
        );
      },
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
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.xs),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
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
    final c = AppSemanticColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 29,
          padding: EdgeInsets.symmetric(vertical: AppSpacingTokens.xs + 2),
          decoration: BoxDecoration(
            color: selected ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: c.textPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppSemanticTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.textPrimary,
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
  bool _isSaving = false;
  int _remainingSeconds = 0;
  int _tapCount = 0;
  Timer? _timer;
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
      builder: (context) {
        final c = AppSemanticColors.of(context);
        return Dialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadiiTokens.lg)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.lg,
              vertical: AppSpacingTokens.lg + 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: c.primaryLight),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Text(
                      l10n.measurementComplete,
                      style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.md),
                Text(
                  '$bpm',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  l10n.breathsPerMinute,
                  style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacingTokens.md),
                Text(
                  l10n.breathCountMessage(_tapCount, widget.selectedDuration),
                  style: AppSemanticTextStyles.caption.copyWith(color: c.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacingTokens.lg),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _remainingSeconds = widget.selectedDuration;
                            _tapCount = 0;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: AppSpacingTokens.sm + 4),
                          decoration: BoxDecoration(
                            color: c.background,
                            borderRadius: BorderRadius.circular(AppRadiiTokens.full),
                          ),
                          child: Text(
                            l10n.measureAgain,
                            textAlign: TextAlign.center,
                            style: AppSemanticTextStyles.body.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacingTokens.sm + 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_isSaving) return;
                          _isSaving = true;
                          final petId = petStore.activePet?.id ?? '';
                          final petName = petStore.activePet?.name ?? l10n.petName;
                          if (petId.isEmpty) {
                            setState(() => _isSaving = false);
                            return;
                          }

                          measurementStore.addMeasurement(
                            petId,
                            Measurement(
                              bpm: bpm,
                              recordedAt: DateTime.now(),
                            ),
                          );
                          notificationStore.addNotification(
                            AppNotification(
                              id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
                              title: l10n.measurementComplete,
                              body: l10n.measurementSavedBpm(bpm),
                              type: NotificationType.measurement,
                              createdAt: DateTime.now(),
                              petName: petName,
                            ),
                          );

                          Navigator.pop(context);
                          setState(() {
                            _isSaving = false;
                            _remainingSeconds = widget.selectedDuration;
                            _tapCount = 0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.measurementSavedBpm(bpm)),
                              backgroundColor: c.primaryLight,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: AppSpacingTokens.sm + 4),
                          decoration: BoxDecoration(
                            color: c.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadiiTokens.full),
                          ),
                          child: Text(
                            l10n.addToGraph,
                            textAlign: TextAlign.center,
                            style: AppSemanticTextStyles.body.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _tapCount = 0;
      _remainingSeconds = widget.selectedDuration;
    });
  }

  void _onTap() {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Scale animation: shrink then bounce back
    _scaleController.forward().then((_) {
      if (mounted) _scaleController.reverse();
    });

    if (!_isRunning) {
      _startTimer();
    }

    setState(() => _tapCount++);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = widget.selectedDuration == 0
        ? 0.0
        : (_remainingSeconds / widget.selectedDuration).clamp(0.0, 1.0);

    return SingleChildScrollView(
      child: Column(
      children: [
        // Timer Duration selector
        Container(
          padding: const EdgeInsets.all(AppSpacingTokens.lg),
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.timerDuration,
                style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Row(
                children: [
                  _DurationChip(
                    label: l10n.duration15s,
                    selected: widget.selectedDuration == 15,
                    onTap: _isRunning ? null : () => widget.onDurationChanged(15),
                  ),
                  const SizedBox(width: AppSpacingTokens.md),
                  _DurationChip(
                    label: l10n.duration30s,
                    selected: widget.selectedDuration == 30,
                    onTap: _isRunning ? null : () => widget.onDurationChanged(30),
                  ),
                  const SizedBox(width: AppSpacingTokens.md),
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
        const SizedBox(height: AppSpacingTokens.lg),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.xl + 16,
            vertical: AppSpacingTokens.md,
          ),
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
          ),
          child: Column(
            children: [
              Text(
                '${_remainingSeconds}s',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w500,
                  color: c.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: c.textPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadiiTokens.full),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 8,
                        width: width * progress,
                        decoration: BoxDecoration(
                          color: c.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadiiTokens.full),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacingTokens.md),
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
                      color: c.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
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
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w500,
                            color: c.textPrimary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.sm),
                        Text(
                          _isRunning ? l10n.tapToStop : l10n.tapToBegin,
                          style: AppSemanticTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isRunning)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacingTokens.sm + 4),
                  child: TextButton.icon(
                    onPressed: _resetTimer,
                    icon: Icon(Icons.refresh, size: 18, color: c.error),
                    label: Text(
                      l10n.reset,
                      style: AppSemanticTextStyles.body.copyWith(
                        color: c.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
    final c = AppSemanticColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.primaryLight : c.surface,
            borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
          ),
          child: Text(
            label,
            style: AppSemanticTextStyles.body.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: c.textPrimary,
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
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.visionRRMode, style: AppSemanticTextStyles.headingLg),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.visionRRModeDescription,
            style: AppSemanticTextStyles.body,
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          Expanded(
            child: Center(
              child: Icon(Icons.videocam, size: 64, color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
