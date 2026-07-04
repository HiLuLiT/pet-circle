import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableVisionRR;
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/utils/formatters.dart';
import 'package:pet_circle/utils/responsive_utils.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/segmented_control.dart';
import 'package:pet_circle/widgets/status_badge.dart';

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
                    style: AppSemanticTextStyles.headingH2.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    l10n.viewerMeasurementRestriction,
                    style: AppSemanticTextStyles.pcBody.copyWith(color: c.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );

          if (!widget.showScaffold) {
            return Container(color: c.background, child: noPermissionContent);
          }
          return Scaffold(backgroundColor: c.background, body: noPermissionContent);
        }

        final content = SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.pcXl),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsiveMaxWidth(context)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.measureRespiratoryRate,
                        style: AppSemanticTextStyles.headingH2,
                      ),
                      const SizedBox(height: AppSpacingTokens.pcLg),
                      // VisionRR camera mode is not shipped yet; when disabled
                      // we skip the manual/vision mode selector and show
                      // manual mode directly. The segmented control only
                      // appears when there is a second mode to switch to.
                      // See kEnableVisionRR in lib/config/app_config.dart.
                      if (kEnableVisionRR) ...[
                        AppSegmentedControl(
                          options: [l10n.manualMode, l10n.visionRRMode],
                          value: _selectedTab == 1
                              ? l10n.visionRRMode
                              : l10n.manualMode,
                          onChanged: (label) => setState(
                            () => _selectedTab = label == l10n.visionRRMode ? 1 : 0,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.pcLg),
                      ],
                      const _MetricsRow(),
                      const SizedBox(height: AppSpacingTokens.pcLg),
                      kEnableVisionRR && _selectedTab == 1
                          ? const _VisionMode()
                          : _ManualMode(
                              selectedDuration: _selectedDuration,
                              onDurationChanged: (value) =>
                                  setState(() => _selectedDuration = value),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        if (!widget.showScaffold) {
          return Container(color: c.background, child: content);
        }

        return Scaffold(
          backgroundColor: c.background,
          body: content,
        );
      },
    );
  }
}

/// "Target" / "Last reading" metric card pair — matches the Figma
/// "Metric Label" component pair shown above the timer card in all three
/// measurement states (Ready / Running / Result).
class _MetricsRow extends StatelessWidget {
  const _MetricsRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final petId = petStore.activePet?.id;
    final latest = petId == null ? null : measurementStore.latestForPet(petId);

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: l10n.target,
            value: l10n.underBpm(settingsStore.elevatedThreshold),
            valueSuffix: l10n.bpm,
          ),
        ),
        const SizedBox(width: AppSpacingTokens.pcMd),
        Expanded(
          child: _MetricCard(
            label: l10n.lastReading,
            value: latest != null ? '${latest.bpm}' : '—',
            valueSuffix: latest != null
                ? '· ${formatTimeAgoShort(latest.recordedAt, l10n)}'
                : null,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    this.valueSuffix,
  });

  final String label;
  final String value;
  final String? valueSuffix;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.pcMd),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcField),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppSemanticTextStyles.pcCaption),
          const SizedBox(height: AppSpacingTokens.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppSemanticTextStyles.headingH2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (valueSuffix != null) ...[
                const SizedBox(width: AppSpacingTokens.xs),
                Text(valueSuffix!, style: AppSemanticTextStyles.pcCaption),
              ],
            ],
          ),
        ],
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
  bool _showResult = false;
  int _remainingSeconds = 0;
  int _tapCount = 0;
  int? _resultBpm;
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
    // Guard against a periodic-tick callback that fires concurrently with
    // dispose() — Timer.cancel() does not interrupt an in-flight callback.
    if (!mounted) return;

    // Calculate BPM: (taps / duration) * 60
    final bpm = (_tapCount / widget.selectedDuration * 60).round();

    setState(() {
      _isRunning = false;
      _showResult = true;
      _resultBpm = bpm;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _showResult = false;
      _resultBpm = null;
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

  void _saveMeasurement(int bpm) {
    if (_isSaving) return;
    _isSaving = true;
    final l10n = AppLocalizations.of(context)!;
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
        titleKey: 'measurementComplete',
        body: l10n.measurementSavedBpm(bpm),
        bodyKey: 'measurementSavedBpm',
        args: [bpm.toString()],
        type: NotificationType.measurement,
        createdAt: DateTime.now(),
        petName: petName,
      ),
    );

    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.measurementSavedBpm(bpm)),
        backgroundColor: AppSemanticColors.of(context).primary,
      ),
    );
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_showResult && _resultBpm != null) {
      return _ResultCard(
        bpm: _resultBpm!,
        onAddToGraph: () => _saveMeasurement(_resultBpm!),
        onMeasureAgain: _resetTimer,
      );
    }

    return _TimerCard(
      selectedDuration: widget.selectedDuration,
      onDurationChanged: widget.onDurationChanged,
      isRunning: _isRunning,
      remainingSeconds: _remainingSeconds,
      tapCount: _tapCount,
      scaleAnimation: _scaleAnimation,
      onTap: _onTap,
      hintText: l10n.measurementHint,
    );
  }
}

/// Ready / Running timer card — matches Figma "Measure - Ready" (402:2019)
/// and "Measure - Running" (474:1291). Both states share the same layout;
/// only the circle contents and progress fill differ.
class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.isRunning,
    required this.remainingSeconds,
    required this.tapCount,
    required this.scaleAnimation,
    required this.onTap,
    required this.hintText,
  });

  final int selectedDuration;
  final ValueChanged<int> onDurationChanged;
  final bool isRunning;
  final int remainingSeconds;
  final int tapCount;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final elapsed = selectedDuration - remainingSeconds;

    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.pcMd),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.timerDuration, style: AppSemanticTextStyles.headingH2),
          const SizedBox(height: AppSpacingTokens.pcMd),
          Row(
            children: [
              _DurationOption(
                label: l10n.duration15s,
                selected: selectedDuration == 15,
                onTap: isRunning ? null : () => onDurationChanged(15),
              ),
              const SizedBox(width: AppSpacingTokens.pcMd),
              _DurationOption(
                label: l10n.duration30s,
                selected: selectedDuration == 30,
                onTap: isRunning ? null : () => onDurationChanged(30),
              ),
              const SizedBox(width: AppSpacingTokens.pcMd),
              _DurationOption(
                label: l10n.duration60s,
                selected: selectedDuration == 60,
                onTap: isRunning ? null : () => onDurationChanged(60),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.pcMd),
          Row(
            children: [
              Expanded(
                child: _DurationProgressTrack(
                  value: selectedDuration == 0 ? 0.0 : elapsed / selectedDuration,
                ),
              ),
              const SizedBox(width: AppSpacingTokens.pcMd),
              Text(
                l10n.elapsedSeconds(elapsed),
                style: AppSemanticTextStyles.labelLRegular.copyWith(
                  color: c.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.pcMd),
          Center(
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedBuilder(
                animation: scaleAnimation,
                builder: (context, child) => Transform.scale(
                  scale: scaleAnimation.value,
                  child: child,
                ),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: c.accentBlushTile,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isRunning
                        ? Text(
                            '$tapCount',
                            style: AppSemanticTextStyles.pcDisplayXxl.copyWith(
                              color: c.accentBlush,
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite, size: 49, color: c.accentBlush),
                              const SizedBox(height: AppSpacingTokens.sm),
                              Text(
                                l10n.tapToBegin,
                                style: AppSemanticTextStyles.labelLSemibold.copyWith(
                                  color: c.accentBlush,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.pcMd),
          Text(
            hintText,
            style: AppSemanticTextStyles.pcCaption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A single duration option in the "Timer duration" row. Unselected options
/// render as plain tertiary-colored text (no chip background); the selected
/// option renders as a blush pill — matches Figma exactly (only the active
/// duration gets a pill background).
class _DurationOption extends StatelessWidget {
  const _DurationOption({
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

    if (!selected) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          label,
          style: AppSemanticTextStyles.labelLRegular.copyWith(
            color: c.textTertiary,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: c.accentBlushTile,
          borderRadius: BorderRadius.circular(AppRadiiTokens.pcPill),
        ),
        child: Text(
          label,
          style: AppSemanticTextStyles.labelMSemibold.copyWith(
            color: c.accentBlush,
          ),
        ),
      ),
    );
  }
}

/// Blush-tinted progress track for the timer countdown — matches the Figma
/// "Views / Progress Bars" instance used on the measurement card (blush
/// track + blush-accent fill, distinct from the default purple
/// [ProgressBar]).
class _DurationProgressTrack extends StatelessWidget {
  const _DurationProgressTrack({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final clamped = value.clamp(0.0, 1.0);
    final radius = BorderRadius.circular(AppRadiiTokens.pcPill);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(color: c.accentBlushTile, borderRadius: radius),
            ),
            FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: clamped,
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: c.accentBlush, borderRadius: radius),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Result state — matches Figma "Measure - Result Screen" (474:1577).
/// Rendered inline in place of the timer card (not a modal dialog).
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.bpm,
    required this.onAddToGraph,
    required this.onMeasureAgain,
  });

  final int bpm;
  final VoidCallback onAddToGraph;
  final VoidCallback onMeasureAgain;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final status = settingsStore.classifyStatus(bpm);
    final badgeText = switch (status) {
      'Critical' => l10n.alertRangeReading,
      'Elevated' => l10n.elevatedRangeReading,
      _ => l10n.withinNormalRange,
    };
    final badgeStatus = switch (status) {
      'Critical' => StatusBadgeStatus.alert,
      'Elevated' => StatusBadgeStatus.elevated,
      _ => StatusBadgeStatus.normal,
    };

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.pcMd,
            vertical: AppSpacingTokens.pcXl,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: c.primaryGhost,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, size: 36, color: c.primary),
              ),
              const SizedBox(height: AppSpacingTokens.pcMd),
              Text(
                l10n.measurementComplete,
                style: AppSemanticTextStyles.pcCaption.copyWith(color: c.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                '$bpm',
                style: AppSemanticTextStyles.pcDisplayXxl.copyWith(color: c.accentBlush),
                textAlign: TextAlign.center,
              ),
              Text(
                l10n.breathsPerMin,
                style: AppSemanticTextStyles.pcCaption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.pcLg),
              StatusBadge(label: badgeText, status: badgeStatus),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.pcLg),
        PrimaryButton(label: l10n.addToGraph, onPressed: onAddToGraph),
        const SizedBox(height: AppSpacingTokens.pcSm),
        PrimaryButton(
          label: l10n.measureAgain,
          variant: PrimaryButtonVariant.outlined,
          onPressed: onMeasureAgain,
        ),
      ],
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
      padding: const EdgeInsets.all(AppSpacingTokens.pcMd),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.visionRRMode, style: AppSemanticTextStyles.headingH2),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.visionRRModeDescription,
            style: AppSemanticTextStyles.pcBody,
          ),
          const SizedBox(height: AppSpacingTokens.pcLg),
          Center(
            child: Icon(Icons.videocam, size: 64, color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}
