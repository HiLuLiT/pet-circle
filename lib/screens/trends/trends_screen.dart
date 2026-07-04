import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/utils/csv_export_helper.dart';
import 'package:pet_circle/utils/display_localizer.dart';
import 'package:pet_circle/utils/responsive_utils.dart';
import 'package:pet_circle/widgets/app_card.dart';
import 'package:pet_circle/widgets/app_dropdown.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/status_badge.dart';
import 'package:fl_chart/fl_chart.dart';

/// Locale-independent identifiers for the trends time-range selector.
///
/// The selected value is stored as one of these stable enum members rather
/// than a localized display string, so switching the app locale never leaves
/// the [DropdownButton] with a value that no longer matches any item.
enum TrendsPeriod { last24Hours, last3Days, last7Days, last30Days, last90Days, customRange }

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen>
    with SingleTickerProviderStateMixin {
  TrendsPeriod _selectedPeriod = TrendsPeriod.last7Days;
  bool _isPeriodOpen = false;
  late final AnimationController _chevronController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

  void _togglePeriodOpen() {
    setState(() {
      _isPeriodOpen = !_isPeriodOpen;
      if (_isPeriodOpen) {
        _chevronController.forward();
      } else {
        _chevronController.reverse();
      }
    });
  }

  /// Maps a localized display label back to its canonical [TrendsPeriod].
  ///
  /// Returns `null` when no period matches the label (e.g. after a locale
  /// switch races an interaction); callers ignore unmatched labels.
  TrendsPeriod? _periodForLabel(String label, AppLocalizations l10n) {
    for (final period in TrendsPeriod.values) {
      if (_periodLabel(period, l10n) == label) return period;
    }
    return null;
  }

  void _selectPeriodLabel(String label, AppLocalizations l10n) {
    final period = _periodForLabel(label, l10n);
    if (period == null) return;
    setState(() {
      _selectedPeriod = period;
      _isPeriodOpen = false;
      _chevronController.reverse();
    });
  }

  String _periodLabel(TrendsPeriod period, AppLocalizations l10n) {
    switch (period) {
      case TrendsPeriod.last24Hours:
        return l10n.last24Hours;
      case TrendsPeriod.last3Days:
        return l10n.last3Days;
      case TrendsPeriod.last7Days:
        return l10n.last7Days;
      case TrendsPeriod.last30Days:
        return l10n.last30Days;
      case TrendsPeriod.last90Days:
        return l10n.last90Days;
      case TrendsPeriod.customRange:
        return l10n.customRange;
    }
  }

  Duration? _periodToDuration(TrendsPeriod period) {
    switch (period) {
      case TrendsPeriod.last24Hours:
        return const Duration(hours: 24);
      case TrendsPeriod.last3Days:
        return const Duration(days: 3);
      case TrendsPeriod.last7Days:
        return const Duration(days: 7);
      case TrendsPeriod.last30Days:
        return const Duration(days: 30);
      case TrendsPeriod.last90Days:
        return const Duration(days: 90);
      case TrendsPeriod.customRange:
        return null;
    }
  }

  List<Measurement> _filterByPeriod(List<Measurement> all) {
    final duration = _periodToDuration(_selectedPeriod);
    if (duration == null) return all;
    final cutoff = DateTime.now().subtract(duration);
    return all.where((m) => m.recordedAt.isAfter(cutoff)).toList();
  }

  void _showExportDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final petId = petStore.activePet?.id ?? '';
    final petName = petStore.activePet?.name ?? l10n.petName;
    final measurements = measurementStore.getMeasurements(petId);
    final csvLines = measurements.map((m) => '${m.recordedAt.toIso8601String()},${m.bpm}').join('\n');
    final csvData = 'Date,BPM\n$csvLines';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusCard),
        title: Text(l10n.exportLabel, style: AppSemanticTextStyles.headingH2),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.csvPreview, style: AppSemanticTextStyles.pcBody),
              SizedBox(height: AppSpacingTokens.pcSm),
              Container(
                padding: EdgeInsets.all(AppSpacingTokens.pcSm),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: AppRadiiTokens.borderRadiusField,
                ),
                child: Text(csvData, style: AppSemanticTextStyles.pcCaption.copyWith(fontFamily: 'monospace', fontSize: 10)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close, style: AppSemanticTextStyles.pcBody.copyWith(color: c.textPrimary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final filename = '${petName}_srr_trends_$timestamp.csv';
                await exportCsv(filename, csvData);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.medicationLogExported)),
                );
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.exportFailedRetry)),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: c.primaryLight,
              shape: RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusField),
            ),
            child: Text(l10n.downloadCsv, style: AppSemanticTextStyles.pcBody.copyWith(color: c.textPrimary)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String petId, Measurement m) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final dateStr = '${m.recordedAt.month}/${m.recordedAt.day}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusCard),
        title: Text(l10n.deleteMeasurement, style: AppSemanticTextStyles.headingH2.copyWith(color: c.textPrimary)),
        content: Text(l10n.deleteMeasurementConfirmation(m.bpm, dateStr), style: AppSemanticTextStyles.pcBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              measurementStore.removeMeasurement(petId, m);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.measurementDeleted)),
              );
            },
            style: TextButton.styleFrom(backgroundColor: c.error),
            child: Text(l10n.deleteMeasurement, style: TextStyle(color: c.surface)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([measurementStore, petStore, userStore]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final c = AppSemanticColors.of(context);
        final access = petStore.accessForActivePet();
        final petName = petStore.activePet?.name ?? l10n.petName;
        final petId = petStore.activePet?.id ?? '';
        final allMeasurements = measurementStore.getMeasurements(petId);
        final filtered = _filterByPeriod(allMeasurements);

        final content = SafeArea(
          child: RefreshIndicator(
            onRefresh: () => measurementStore.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.pcXl),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: responsiveMaxWidth(context)),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(l10n.healthTrends, style: AppSemanticTextStyles.headingH2),
              const SizedBox(height: AppSpacingTokens.pcXs),
              Text(
                filtered.length < allMeasurements.length
                    ? l10n.recordingsInPeriod(petName, filtered.length, allMeasurements.length)
                    : l10n.recordingsTotal(petName, allMeasurements.length),
                style: AppSemanticTextStyles.pcLabelMuted,
              ),
              const SizedBox(height: AppSpacingTokens.pcMd),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppDropdown(
                      label: '',
                      value: _periodLabel(_selectedPeriod, l10n),
                      onTap: _togglePeriodOpen,
                      isOpen: _isPeriodOpen,
                      chevronController: _chevronController,
                      options: TrendsPeriod.values
                          .map((period) => _periodLabel(period, l10n))
                          .toList(),
                      onOptionSelected: (label) => _selectPeriodLabel(label, l10n),
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.pcSm),
                  PrimaryButton(
                    label: l10n.exportLabel,
                    variant: PrimaryButtonVariant.miniPrimary,
                    backgroundColor: c.textPrimary,
                    foregroundColor: c.surface,
                    onPressed: () => _showExportDialog(context),
                    trailingIcon: Icon(Icons.file_download_outlined, color: c.surface),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.pcMd),
              _SrrCard(filtered: filtered),
              const SizedBox(height: AppSpacingTokens.pcMd),
              _MetricRow(filtered: filtered),
              if (filtered.isNotEmpty) ...[
                const SizedBox(height: AppSpacingTokens.pcMd),
                Text(l10n.measurementHistory, style: AppSemanticTextStyles.headingH2),
                const SizedBox(height: AppSpacingTokens.pcSm),
                ...filtered.map((m) {
                  final dateStr = '${m.recordedAt.month}/${m.recordedAt.day} · ${m.recordedAt.hour.toString().padLeft(2, '0')}:${m.recordedAt.minute.toString().padLeft(2, '0')}';
                  final status = settingsStore.classifyStatus(m.bpm);
                  final badgeStatus = status == 'Normal'
                      ? StatusBadgeStatus.normal
                      : status == 'Elevated'
                          ? StatusBadgeStatus.elevated
                          : StatusBadgeStatus.alert;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacingTokens.pcSm),
                    child: Dismissible(
                      key: ValueKey('${m.recordedAt.millisecondsSinceEpoch}-${m.bpm}'),
                      direction: access.canDeleteMeasurements
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: AppSpacingTokens.pcMd),
                        decoration: BoxDecoration(
                          color: c.error,
                          borderRadius: AppRadiiTokens.borderRadiusCard,
                        ),
                        child: Icon(Icons.delete, color: c.surface),
                      ),
                      confirmDismiss: (_) async {
                        if (!access.canDeleteMeasurements) return false;
                        _confirmDelete(context, petId, m);
                        return false;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacingTokens.pcMd),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: AppRadiiTokens.borderRadiusCard,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${m.bpm} ${l10n.bpm}', style: AppSemanticTextStyles.labelLSemibold),
                                  Text(dateStr, style: AppSemanticTextStyles.pcLabelMuted),
                                ],
                              ),
                            ),
                            StatusBadge(
                              label: localizeStatus(status, l10n),
                              status: badgeStatus,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
                ],
              ),
            ),
              ),
            ),
          ),
          ),
        );

        if (!widget.showScaffold) {
          return Container(color: c.background, child: content);
        }
        return Scaffold(backgroundColor: c.background, body: content);
      },
    );
  }
}

/// Main "Sleeping respiratory rate" card — matches Figma node 402:2096:
/// title, big avg-BPM headline, area chart, and three legend badges
/// (Normal / Elevated / Alert) using the candy tile accent colors.
class _SrrCard extends StatelessWidget {
  const _SrrCard({required this.filtered});

  final List<Measurement> filtered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final bpms = filtered.map((m) => m.bpm).toList();
    final avgLabel = bpms.isEmpty
        ? '--'
        : (bpms.reduce((a, b) => a + b) / bpms.length).round().toString();
    final elevated = settingsStore.elevatedThreshold;
    final critical = settingsStore.criticalThreshold;

    return AppCard(
      variant: AppCardVariant.surface,
      padding: const EdgeInsets.all(AppSpacingTokens.pcLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.srrOverTime, style: AppSemanticTextStyles.pcLabelMuted),
          const SizedBox(height: AppSpacingTokens.pcSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(avgLabel, style: AppSemanticTextStyles.pcDisplayXl),
              const SizedBox(width: AppSpacingTokens.pcXs),
              Text(l10n.avgBpm, style: AppSemanticTextStyles.labelLRegular.copyWith(color: c.textSecondary)),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.pcSm),
          _SrrChart(measurements: filtered),
          const SizedBox(height: AppSpacingTokens.pcSm),
          Wrap(
            spacing: AppSpacingTokens.pcXs,
            runSpacing: AppSpacingTokens.pcXs,
            children: [
              _LegendBadge(
                bg: c.accentPeriwinkleTile,
                dot: c.accentPeriwinkle,
                label: l10n.legendNormal(elevated),
              ),
              _LegendBadge(
                bg: c.accentButterTile,
                dot: c.accentButter,
                label: l10n.legendElevated(elevated, critical),
              ),
              _LegendBadge(
                bg: c.accentBlushTile,
                dot: c.accentBlush,
                label: l10n.legendAlert(critical),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pill legend badge for the SRR chart — tile bg + accent dot/text, matching
/// the Figma "Badge" component instances in node 402:2096.
class _LegendBadge extends StatelessWidget {
  const _LegendBadge({required this.bg, required this.dot, required this.label});

  final Color bg;
  final Color dot;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: AppSpacingTokens.pcSm, right: AppSpacingTokens.pcMd, top: AppSpacingTokens.pcXs, bottom: AppSpacingTokens.pcXs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadiiTokens.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacingTokens.pcXs),
          Text(label, style: AppSemanticTextStyles.labelSSemibold.copyWith(color: dot)),
        ],
      ),
    );
  }
}

/// Two-tile metric row below the SRR card — "Reading range" (min-max bpm)
/// and "Readings" (color-coded normal/elevated/alert counts), matching
/// Figma node 402:2096's "Metric Label" instances.
class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.filtered});

  final List<Measurement> filtered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final bpms = filtered.map((m) => m.bpm).toList();
    final rangeLabel = bpms.isEmpty
        ? '--'
        : '${bpms.reduce((a, b) => a < b ? a : b)}-${bpms.reduce((a, b) => a > b ? a : b)}';
    final normal = filtered.where((m) => m.bpm < settingsStore.elevatedThreshold).length;
    final elevated = filtered
        .where((m) => m.bpm >= settingsStore.elevatedThreshold && m.bpm < settingsStore.criticalThreshold)
        .length;
    final alert = filtered.where((m) => m.bpm >= settingsStore.criticalThreshold).length;

    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: l10n.readingRange,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(rangeLabel, style: AppSemanticTextStyles.headingH2),
                const SizedBox(width: AppSpacingTokens.pcXs),
                Text(l10n.bpm.toLowerCase(), style: AppSemanticTextStyles.labelSRegular.copyWith(color: c.textTertiary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.pcSm),
        Expanded(
          child: _MetricTile(
            label: l10n.readingsLabel,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$normal', style: AppSemanticTextStyles.headingH2.copyWith(color: c.accentPeriwinkle)),
                  TextSpan(text: ' ', style: AppSemanticTextStyles.headingH2),
                  TextSpan(text: '$elevated', style: AppSemanticTextStyles.headingH2.copyWith(color: c.accentButter)),
                  TextSpan(text: ' ', style: AppSemanticTextStyles.headingH2),
                  TextSpan(text: '$alert', style: AppSemanticTextStyles.headingH2.copyWith(color: c.accentBlush)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.surface,
      padding: const EdgeInsets.all(AppSpacingTokens.pcMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppSemanticTextStyles.labelSRegular),
          const SizedBox(height: AppSpacingTokens.pcXs),
          child,
        ],
      ),
    );
  }
}

class _SrrChart extends StatelessWidget {
  const _SrrChart({this.measurements = const []});

  final List<Measurement> measurements;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (measurements.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacingTokens.pcLg),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: AppRadiiTokens.borderRadiusField,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 40, color: c.textTertiary),
            const SizedBox(height: AppSpacingTokens.pcSm),
            Text(l10n.noMeasurementsYet, style: AppSemanticTextStyles.labelLSemibold),
            const SizedBox(height: AppSpacingTokens.pcXs),
            Text(
              l10n.noMeasurementsDescription,
              style: AppSemanticTextStyles.pcCaption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final ordered = measurements.reversed.toList();
    final spots = ordered.indexed
        .map((entry) => FlSpot(entry.$1.toDouble(), entry.$2.bpm.toDouble()))
        .toList();

    final dateFormat = DateFormat('MMM d');
    final labels = ordered
        .map((m) => dateFormat.format(m.recordedAt))
        .toList();
    final labelStep = (labels.length / 6).ceil().clamp(1, labels.length);

    final maxBpm = spots.isEmpty ? 50.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxY = max(50.0, maxBpm + 10.0);

    final labelColor = c.textTertiary;
    final chartColor = c.accentPeriwinkle;
    final gridColor = c.textTertiary;

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: AppSpacingTokens.pcMd,
        right: AppSpacingTokens.pcSm,
        bottom: AppSpacingTokens.pcXs,
        left: AppSpacingTokens.pcXs,
      ),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: AppRadiiTokens.borderRadiusField,
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: false,
            verticalInterval: labelStep.toDouble(),
            getDrawingVerticalLine: (_) => FlLine(
              color: gridColor,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  if (value % 10 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: AppSemanticTextStyles.caption.copyWith(
                        color: labelColor,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: labelStep.toDouble(),
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % labelStep != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      labels[index],
                      style: AppSemanticTextStyles.caption.copyWith(
                        color: labelColor,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: settingsStore.elevatedThreshold.toDouble(),
                color: gridColor,
                strokeWidth: 1,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (_) => l10n.legendNormal(settingsStore.elevatedThreshold),
                  style: AppSemanticTextStyles.caption.copyWith(
                    color: labelColor,
                  ),
                ),
              ),
              HorizontalLine(
                y: settingsStore.criticalThreshold.toDouble(),
                color: gridColor,
                strokeWidth: 1,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (_) => l10n.legendAlert(settingsStore.criticalThreshold),
                  style: AppSemanticTextStyles.caption.copyWith(
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: chartColor,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 5,
                  color: chartColor,
                  strokeWidth: 2,
                  strokeColor: c.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    chartColor.withValues(alpha: 0.3),
                    chartColor.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
