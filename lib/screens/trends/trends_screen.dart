import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/utils/csv_export_helper.dart';
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
    final c = AppColorsTheme.of(context);
    final petId = petStore.activePet?.id ?? '';
    final petName = petStore.activePet?.name ?? l10n.petName;
    final measurements = measurementStore.getMeasurements(petId);
    final csvLines = measurements.map((m) => '${m.recordedAt.toIso8601String()},${m.bpm}').join('\n');
    final csvData = 'Date,BPM\n$csvLines';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.medium)),
        title: Text(l10n.exportLabel, style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.csvPreview, style: AppTextStyles.body),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.offWhite,
                  borderRadius: const BorderRadius.all(AppRadii.sm),
                ),
                child: Text(csvData, style: AppTextStyles.caption.copyWith(fontFamily: 'monospace', fontSize: 10)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close, style: AppTextStyles.body.copyWith(color: c.chocolate)),
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
              backgroundColor: c.lightBlue,
              shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.small)),
            ),
            child: Text(l10n.downloadCsv, style: AppTextStyles.body.copyWith(color: c.chocolate)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String petId, Measurement m) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final dateStr = '${m.recordedAt.month}/${m.recordedAt.day}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.medium)),
        title: Text(l10n.deleteMeasurement, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
        content: Text(l10n.deleteMeasurementConfirmation(m.bpm, dateStr), style: AppTextStyles.body),
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
            style: TextButton.styleFrom(backgroundColor: c.cherry),
            child: Text(l10n.deleteMeasurement, style: TextStyle(color: c.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([measurementStore, petStore]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final c = AppColorsTheme.of(context);
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: AppSpacing.md),
              Text(l10n.healthTrends, style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.sm),
              Text('$petName • ${allMeasurements.length} recordings', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: c.offWhite,
                      borderRadius: const BorderRadius.all(AppRadii.xs),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPeriod,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        style: AppTextStyles.body,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: c.lightBlue,
                        borderRadius: const BorderRadius.all(AppRadii.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_download, size: 16, color: c.chocolate),
                          const SizedBox(width: 8),
                          Text(l10n.exportLabel, style: AppTextStyles.body),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _StatGrid(filtered: filtered),
              const SizedBox(height: AppSpacing.lg),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.srrOverTime, style: AppTextStyles.heading3),
                    const SizedBox(height: AppSpacing.md),
                    _BadgeRow(),
                    const SizedBox(height: AppSpacing.sm),
                    _BadgeRowSecond(),
                    const SizedBox(height: AppSpacing.md),
                    _SrrChart(measurements: filtered),
                  ],
                ),
              ),
              if (filtered.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.measurementHistory, style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.sm + 4),
                ...filtered.map((m) {
                  final dateStr = '${m.recordedAt.month}/${m.recordedAt.day} ${m.recordedAt.hour}:${m.recordedAt.minute.toString().padLeft(2, '0')}';
                  final status = settingsStore.classifyStatus(m.bpm);
                  final statusColor = status == 'Normal' ? c.lightBlue : status == 'Elevated' ? c.lightYellow : c.cherry;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: ValueKey('${m.recordedAt.millisecondsSinceEpoch}-${m.bpm}'),
                      direction: access.canDeleteMeasurements
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: c.cherry,
                          borderRadius: const BorderRadius.all(AppRadii.small),
                        ),
                        child: Icon(Icons.delete, color: c.white),
                      ),
                      confirmDismiss: (_) async {
                        if (!access.canDeleteMeasurements) return false;
                        _confirmDelete(context, petId, m);
                        return false;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: c.offWhite,
                          borderRadius: const BorderRadius.all(AppRadii.small),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${m.bpm} BPM', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: c.chocolate)),
                                  Text(dateStr, style: AppTextStyles.caption.copyWith(color: c.chocolate)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: const BorderRadius.all(AppRadii.full),
                              ),
                              child: Text(status, style: AppTextStyles.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: c.chocolate)),
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
        );

        if (!widget.showScaffold) {
          return Container(color: c.white, child: content);
        }
        return Scaffold(backgroundColor: c.white, body: content);
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
            const SizedBox(width: 8),
            _StatCard(title: l10n.range, value: '--', footnote: l10n.minMax),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _StatCard(title: l10n.trend, value: '--', footnote: l10n.bpmChange),
            const SizedBox(width: 8),
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
          const SizedBox(width: 8),
          _StatCard(title: l10n.range, value: '$minBpm-$maxBpm', footnote: l10n.minMax),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _StatCard(title: l10n.trend, value: trendStr, footnote: l10n.bpmChange),
          const SizedBox(width: 8),
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
    final c = AppColorsTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.offWhite,
        borderRadius: const BorderRadius.all(AppRadii.medium),
      ),
      child: child,
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow();

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Row(children: [
      _LegendBadge(color: c.lightBlue, label: 'Normal (<30)'),
      const SizedBox(width: 8),
      _LegendBadge(color: c.lightYellow, label: 'Elevated (30-40)'),
    ]);
  }
}

class _BadgeRowSecond extends StatelessWidget {
  const _BadgeRowSecond();

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return _LegendBadge(color: c.cherry, label: 'Alert (>40)');
  }
}

class _LegendBadge extends StatelessWidget {
  const _LegendBadge({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.white,
        borderRadius: const BorderRadius.all(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: c.chocolate)),
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
    final c = AppColorsTheme.of(context);
    return Expanded(
      child: Container(
        height: 109,
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: c.white,
          borderRadius: const BorderRadius.all(AppRadii.small),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: AppTextStyles.heading2.copyWith(fontSize: 24)),
            const Spacer(),
            Text(footnote, style: AppTextStyles.caption),
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
    final c = AppColorsTheme.of(context);
    final normal = measurements.where((m) => m.bpm < settingsStore.elevatedThreshold).length;
    final elevated = measurements.where((m) => m.bpm >= settingsStore.elevatedThreshold && m.bpm < settingsStore.criticalThreshold).length;
    final critical = measurements.where((m) => m.bpm >= settingsStore.criticalThreshold).length;
    return Expanded(
      child: Container(
        height: 109,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.white,
          borderRadius: const BorderRadius.all(AppRadii.small),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.status, style: AppTextStyles.caption.copyWith(fontSize: 12)),
            const SizedBox(height: 16),
            Row(children: [
              _StatusPill(value: '$normal', color: c.lightBlue),
              const SizedBox(width: 8),
              _StatusPill(value: '$elevated', color: c.lightYellow),
              const SizedBox(width: 8),
              _StatusPill(value: '$critical', color: c.cherry, muted: critical == 0),
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
      Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: color)),
      const SizedBox(height: 4),
      Container(
        width: 27, height: 2,
        decoration: BoxDecoration(
          color: muted ? color.withValues(alpha: 0.4) : color,
          borderRadius: const BorderRadius.all(AppRadii.xs),
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
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (measurements.isEmpty) {
      return Container(
        height: 280,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.white,
          borderRadius: const BorderRadius.all(AppRadii.small),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: c.chocolate.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(l10n.noMeasurementsYet, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
            const SizedBox(height: 8),
            Text(
              l10n.noMeasurementsDescription,
              style: AppTextStyles.body.copyWith(color: c.chocolate),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Build chronological list (reversed from reversed-order source list)
    final ordered = measurements.reversed.toList();
    final spots = ordered.indexed
        .map((entry) => FlSpot(entry.$1.toDouble(), entry.$2.bpm.toDouble()))
        .toList();

    // X-axis labels: show up to 6 evenly-spaced date strings to avoid crowding
    final labels = ordered
        .map((m) => '${m.recordedAt.month}/${m.recordedAt.day}')
        .toList();
    final labelStep = (labels.length / 6).ceil().clamp(1, labels.length);

    final maxBpm = spots.isEmpty ? 50.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxY = max(50.0, maxBpm + 10.0);

    final chocolateColor = c.chocolate;
    final offWhiteColor = c.offWhite;
    final blueColor = c.blue;
    final whiteColor = c.white;

    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, right: 12, bottom: 4, left: 4),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: const BorderRadius.all(AppRadii.small),
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
            horizontalInterval: 10,
            verticalInterval: labelStep.toDouble(),
            getDrawingHorizontalLine: (_) => FlLine(
              color: offWhiteColor,
              strokeWidth: 0.5,
              dashArray: [3, 3],
            ),
            getDrawingVerticalLine: (_) => FlLine(
              color: offWhiteColor,
              strokeWidth: 0.5,
              dashArray: [3, 3],
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: chocolateColor, width: 1),
              left: BorderSide(color: chocolateColor, width: 1),
              top: BorderSide.none,
              right: BorderSide.none,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value % 10 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: chocolateColor,
                        fontSize: 10,
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
                reservedSize: 22,
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
                      style: AppTextStyles.caption.copyWith(
                        color: chocolateColor,
                        fontSize: 10,
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
                color: chocolateColor,
                strokeWidth: 1,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (_) => 'Normal Threshold (${settingsStore.elevatedThreshold} BPM)',
                  style: AppTextStyles.caption.copyWith(
                    color: chocolateColor,
                    fontSize: 9,
                  ),
                ),
              ),
              HorizontalLine(
                y: settingsStore.criticalThreshold.toDouble(),
                color: chocolateColor,
                strokeWidth: 1,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (_) => 'Alert Threshold (${settingsStore.criticalThreshold} BPM)',
                  style: AppTextStyles.caption.copyWith(
                    color: chocolateColor,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: blueColor,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: blueColor,
                  strokeWidth: 2,
                  strokeColor: whiteColor,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    blueColor.withValues(alpha: 0.25),
                    blueColor.withValues(alpha: 0.0),
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
