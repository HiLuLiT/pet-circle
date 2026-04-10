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
import 'package:pet_circle/utils/responsive_utils.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  String? _selectedPeriod;

  Duration? _periodToDuration(String period, AppLocalizations l10n) {
    if (period == l10n.last24Hours) return const Duration(hours: 24);
    if (period == l10n.last3Days) return const Duration(days: 3);
    if (period == l10n.last7Days) return const Duration(days: 7);
    if (period == l10n.last30Days) return const Duration(days: 30);
    if (period == l10n.last90Days) return const Duration(days: 90);
    return null;
  }

  List<Measurement> _filterByPeriod(List<Measurement> all, AppLocalizations l10n) {
    final duration = _periodToDuration(_selectedPeriod ?? l10n.last7Days, l10n);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadiiTokens.lg)),
        title: Text(l10n.exportLabel, style: AppSemanticTextStyles.headingLg),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.csvPreview, style: AppSemanticTextStyles.body),
              SizedBox(height: AppSpacingTokens.sm + 4),
              Container(
                padding: EdgeInsets.all(AppSpacingTokens.sm + 4),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                ),
                child: Text(csvData, style: AppSemanticTextStyles.caption.copyWith(fontFamily: 'monospace', fontSize: 10)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
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
                  const SnackBar(content: Text('Export failed. Please try again.')),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: c.primaryLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadiiTokens.sm)),
            ),
            child: Text(l10n.downloadCsv, style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadiiTokens.lg)),
        title: Text(l10n.deleteMeasurement, style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
        content: Text(l10n.deleteMeasurementConfirmation(m.bpm, dateStr), style: AppSemanticTextStyles.body),
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
        final periodOptions = [
          l10n.last24Hours,
          l10n.last3Days,
          l10n.last7Days,
          l10n.last30Days,
          l10n.last90Days,
          l10n.customRange,
        ];

        _selectedPeriod ??= l10n.last7Days;
        final petName = petStore.activePet?.name ?? l10n.petName;
        final petId = petStore.activePet?.id ?? '';
        final allMeasurements = measurementStore.getMeasurements(petId);
        final filtered = _filterByPeriod(allMeasurements, l10n);

        final content = SafeArea(
          child: RefreshIndicator(
            onRefresh: () => measurementStore.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: responsiveMaxWidth(context)),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: AppSpacingTokens.md),
              Text(l10n.healthTrends, style: AppSemanticTextStyles.title3),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                filtered.length < allMeasurements.length
                    ? '$petName • ${filtered.length} of ${allMeasurements.length} recordings in this period'
                    : '$petName • ${allMeasurements.length} recordings',
                style: AppSemanticTextStyles.body,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Wrap(
                spacing: AppSpacingTokens.sm,
                runSpacing: AppSpacingTokens.sm + 4,
                children: [
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm + 4),
                    decoration: BoxDecoration(
                      color: c.background,
                      borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPeriod,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        style: AppSemanticTextStyles.body,
                        items: periodOptions
                            .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedPeriod = value);
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showExportDialog(context),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm + 4),
                      decoration: BoxDecoration(
                        color: c.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_download, size: 16, color: c.textPrimary),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Text(l10n.exportLabel, style: AppSemanticTextStyles.body),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _StatGrid(filtered: filtered),
              const SizedBox(height: AppSpacingTokens.lg),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.srrOverTime, style: AppSemanticTextStyles.headingLg),
                    const SizedBox(height: AppSpacingTokens.md),
                    _BadgeRow(),
                    const SizedBox(height: AppSpacingTokens.sm),
                    _BadgeRowSecond(),
                    const SizedBox(height: AppSpacingTokens.md),
                    _SrrChart(measurements: filtered),
                  ],
                ),
              ),
              if (filtered.isNotEmpty) ...[
                const SizedBox(height: AppSpacingTokens.lg),
                Text(l10n.measurementHistory, style: AppSemanticTextStyles.headingLg),
                const SizedBox(height: AppSpacingTokens.sm + 4),
                ...filtered.map((m) {
                  final dateStr = '${m.recordedAt.month}/${m.recordedAt.day} ${m.recordedAt.hour}:${m.recordedAt.minute.toString().padLeft(2, '0')}';
                  final status = settingsStore.classifyStatus(m.bpm);
                  final statusColor = status == 'Normal' ? c.primaryLight : status == 'Elevated' ? c.warning : c.error;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
                    child: Dismissible(
                      key: ValueKey('${m.recordedAt.millisecondsSinceEpoch}-${m.bpm}'),
                      direction: access.canDeleteMeasurements
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: AppSpacingTokens.md + 4),
                        decoration: BoxDecoration(
                          color: c.error,
                          borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                        ),
                        child: Icon(Icons.delete, color: c.surface),
                      ),
                      confirmDismiss: (_) async {
                        if (!access.canDeleteMeasurements) return false;
                        _confirmDelete(context, petId, m);
                        return false;
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacingTokens.md, vertical: AppSpacingTokens.sm + 4),
                        decoration: BoxDecoration(
                          color: c.background,
                          borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                            ),
                            SizedBox(width: AppSpacingTokens.sm + 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${m.bpm} BPM', style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary)),
                                  Text(dateStr, style: AppSemanticTextStyles.caption.copyWith(color: c.textPrimary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppRadiiTokens.full),
                              ),
                              child: Text(status, style: AppSemanticTextStyles.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: c.textPrimary)),
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
          return Container(color: c.surface, child: content);
        }
        return Scaffold(backgroundColor: c.surface, body: content);
      },
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.filtered});

  final List<Measurement> filtered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (filtered.isEmpty) {
      return _SectionCard(
        child: Column(children: [
          Row(children: [
            _StatCard(title: l10n.averageSrr, value: '--', footnote: l10n.bpm),
            const SizedBox(width: AppSpacingTokens.sm),
            _StatCard(title: l10n.range, value: '--', footnote: l10n.minMax),
          ]),
          const SizedBox(height: AppSpacingTokens.sm),
          Row(children: [
            _StatCard(title: l10n.trend, value: '--', footnote: l10n.bpmChange),
            const SizedBox(width: AppSpacingTokens.sm),
            _StatusCard(measurements: filtered),
          ]),
        ]),
      );
    }

    final bpms = filtered.map((m) => m.bpm).toList();
    final avg = (bpms.reduce((a, b) => a + b) / bpms.length).round();
    final minBpm = bpms.reduce((a, b) => a < b ? a : b);
    final maxBpm = bpms.reduce((a, b) => a > b ? a : b);
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = filtered.where((m) => m.recordedAt.isAfter(weekAgo)).toList();
    final older = filtered.where((m) => !m.recordedAt.isAfter(weekAgo)).toList();
    final recentAvg = recent.isEmpty ? avg : (recent.map((m) => m.bpm).reduce((a, b) => a + b) / recent.length).round();
    final olderAvg = older.isEmpty ? recentAvg : (older.map((m) => m.bpm).reduce((a, b) => a + b) / older.length).round();
    final trend = recentAvg - olderAvg;
    final trendStr = trend >= 0 ? '+$trend' : '$trend';

    return _SectionCard(
      child: Column(children: [
        Row(children: [
          _StatCard(title: l10n.averageSrr, value: '$avg', footnote: l10n.bpm),
          const SizedBox(width: AppSpacingTokens.sm),
          _StatCard(title: l10n.range, value: '$minBpm-$maxBpm', footnote: l10n.minMax),
        ]),
        const SizedBox(height: AppSpacingTokens.sm),
        Row(children: [
          _StatCard(title: l10n.trend, value: trendStr, footnote: l10n.bpmChange),
          const SizedBox(width: AppSpacingTokens.sm),
          _StatusCard(measurements: filtered),
        ]),
      ]),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
      ),
      child: child,
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow();

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Wrap(
      spacing: AppSpacingTokens.sm,
      runSpacing: AppSpacingTokens.sm,
      children: [
        _LegendBadge(color: c.primaryLight, label: 'Normal (<30)'),
        _LegendBadge(color: c.warning, label: 'Elevated (30-40)'),
      ],
    );
  }
}

class _BadgeRowSecond extends StatelessWidget {
  const _BadgeRowSecond();

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return _LegendBadge(color: c.error, label: 'Alert (>40)');
  }
}

class _LegendBadge extends StatelessWidget {
  const _LegendBadge({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm, vertical: AppSpacingTokens.xs),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadiiTokens.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacingTokens.xs),
          Text(label, style: AppSemanticTextStyles.caption.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.footnote});

  final String title;
  final String value;
  final String footnote;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Expanded(
      child: Container(
        height: 109,
        padding: const EdgeInsets.all(AppSpacingTokens.sm + 4),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppSemanticTextStyles.caption),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(value, style: AppSemanticTextStyles.title3.copyWith(fontSize: 24)),
            const Spacer(),
            Text(footnote, style: AppSemanticTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.measurements});

  final List<Measurement> measurements;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final normal = measurements.where((m) => m.bpm < settingsStore.elevatedThreshold).length;
    final elevated = measurements.where((m) => m.bpm >= settingsStore.elevatedThreshold && m.bpm < settingsStore.criticalThreshold).length;
    final critical = measurements.where((m) => m.bpm >= settingsStore.criticalThreshold).length;
    return Expanded(
      child: Container(
        height: 109,
        padding: EdgeInsets.all(AppSpacingTokens.sm + 4),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.status, style: AppSemanticTextStyles.caption.copyWith(fontSize: 12)),
            const SizedBox(height: AppSpacingTokens.md),
            Row(children: [
              _StatusPill(value: '$normal', color: c.primaryLight),
              const SizedBox(width: AppSpacingTokens.sm),
              _StatusPill(value: '$elevated', color: c.warning),
              const SizedBox(width: AppSpacingTokens.sm),
              _StatusPill(value: '$critical', color: c.error, muted: critical == 0),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.value, required this.color, this.muted = false});

  final String value;
  final Color color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: color)),
      const SizedBox(height: AppSpacingTokens.xs),
      Container(
        width: 27, height: 2,
        decoration: BoxDecoration(
          color: muted ? color.withValues(alpha: 0.4) : color,
          borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
        ),
      ),
    ]);
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
        height: 392,
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(AppRadiiTokens.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: c.textSecondary.withValues(alpha: 0.4)),
            SizedBox(height: AppSpacingTokens.sm + 4),
            Text(l10n.noMeasurementsYet, style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
            const SizedBox(height: AppSpacingTokens.sm),
            Text(
              l10n.noMeasurementsDescription,
              style: AppSemanticTextStyles.body.copyWith(color: c.textSecondary),
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

    final labelColor = c.textSecondary;
    final chartColor = c.info;
    final gridColor = c.divider;

    return Container(
      height: 392,
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: AppSpacingTokens.md,
        right: AppSpacingTokens.sm,
        bottom: AppSpacingTokens.xs,
        left: AppSpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadiiTokens.md),
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
                  labelResolver: (_) => 'Normal (${settingsStore.elevatedThreshold})',
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
                  labelResolver: (_) => 'Alert (${settingsStore.criticalThreshold})',
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
