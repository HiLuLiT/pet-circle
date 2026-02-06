import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/app_header.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  static const _lightBlue = Color(0xFF75ACFF);
  static const _blue = Color(0xFF146FD9);
  static const _yellow = Color(0xFFFFE476);
  static const _cherry = Color(0xFFE64E60);

  int _selectedTab = 0;

  void _openAddMedicationSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddMedicationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                userName: MockData.currentOwnerUser.name,
                userImageUrl: MockData.currentOwnerUser.avatarUrl,
                petName: MockData.princess.name,
                petImageUrl: MockData.princess.imageUrl,
                onAvatarTap: () {
                  // Navigate to settings
                  Navigator.of(context).pushNamed('/settings', arguments: 'owner');
                },
                onNotificationTap: () {
                  // TODO: Navigate to notifications
                },
              ),
              const SizedBox(height: 40),
              Text(l10n.healthTrends, style: AppTextStyles.heading2),
              const SizedBox(height: 32),
              _TrendsTabs(
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 24),
              if (_selectedTab == 0)
                _TrendsOverview(
                  onOpenMedication: _openAddMedicationSheet,
                )
              else if (_selectedTab == 1)
                _MeasurementHistory(
                  onExport: () {},
                )
              else
                _MedicationManagement(
                  onAddMedication: _openAddMedicationSheet,
                ),
            ],
          ),
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


class _TrendsTabs extends StatelessWidget {
  const _TrendsTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _TrendsTab(
            selected: selectedIndex == 0,
            icon: Icons.monitor_heart,
            onTap: () => onChanged(0),
          ),
          _TrendsTab(
            selected: selectedIndex == 1,
            icon: Icons.bar_chart,
            onTap: () => onChanged(1),
          ),
          _TrendsTab(
            selected: selectedIndex == 2,
            icon: Icons.medication,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

class _TrendsTab extends StatelessWidget {
  const _TrendsTab({
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 29,
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppColors.burgundy, size: 18),
        ),
      ),
    );
  }
}

class _TrendsOverview extends StatelessWidget {
  const _TrendsOverview({required this.onOpenMedication});

  final VoidCallback onOpenMedication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _SectionCard(
          child: _MetricRow(
            label: l10n.averageSrr,
            value: '31',
            subLabel: l10n.breathsPerMinute,
            icon: Icons.show_chart,
          ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          child: _MetricRow(
            label: l10n.sevenDayTrend,
            value: '+4',
            subLabel: l10n.bpmChange,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          child: _MetricRow(
            label: l10n.sevenDayTrend,
            value: '1',
            subLabel: l10n.activeTreatments,
            icon: Icons.medication,
          ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.srrOverTime,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              const _BadgeRow(),
              const SizedBox(height: 8),
              const _BadgeRowSecond(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.medicationTimeline, style: AppTextStyles.heading3),
              const SizedBox(height: 4),
              Text(
                'Customize the look and feel',
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medication, color: AppColors.burgundy),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Furosemide',
                                style: AppTextStyles.body),
                            Text('20mg', style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Jan 6',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.burgundy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 36,
                child: TextButton(
                  onPressed: onOpenMedication,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF75ACFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    l10n.addMedication,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.burgundy,
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

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.icon,
  });

  final String label;
  final String value;
  final String subLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.heading1.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(subLabel, style: AppTextStyles.caption.copyWith(fontSize: 12)),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF146FD9)),
        ),
      ],
    );
  }
}

void _exportMedicationLog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  const csvData = 'Medication,Dosage,Frequency,Start Date,End Date,Prescribed By\n'
      'Pimobendan,5mg,Twice daily,2025-01-01,Ongoing,Dr. Smith DVM\n'
      'Furosemide,20mg,Once daily,2025-01-15,2025-03-15,Dr. Smith DVM\n'
      'Enalapril,2.5mg,Once daily,2025-02-01,Ongoing,Dr. Johnson DVM\n';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.exportMedicationLog, style: AppTextStyles.heading3),
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
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(csvData, style: AppTextStyles.caption.copyWith(fontFamily: 'monospace', fontSize: 10)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close, style: AppTextStyles.body.copyWith(color: AppColors.burgundy)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.medicationLogExported)),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF75ACFF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(l10n.downloadCsv, style: AppTextStyles.body.copyWith(color: AppColors.burgundy)),
        ),
      ],
    ),
  );
}

class _MedicationManagement extends StatelessWidget {
  const _MedicationManagement({required this.onAddMedication});

  final VoidCallback onAddMedication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.medicationManagement, style: AppTextStyles.heading3),
            SizedBox(
              height: 32,
              child: TextButton.icon(
                onPressed: onAddMedication,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF75ACFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                icon: const Icon(Icons.add, color: AppColors.burgundy, size: 16),
                label: Text(
                  l10n.addMedication,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.burgundy,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Princess • 0 active treatments',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 24),
        _SectionCard(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medication, color: AppColors.burgundy),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noMedicationsRecorded,
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                "Keep track of Luna's medications, dosages, and treatment schedules. "
                'Add medication records to monitor health trends alongside respiratory data.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 40,
                child: TextButton.icon(
                  onPressed: onAddMedication,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF75ACFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: AppColors.burgundy, size: 16),
                  label: Text(
                    l10n.addMedication,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.burgundy,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline,
                    color: Color(0xFF146FD9)),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.clinicalRecordInformation,
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Medication data is stored locally and included in exported clinical reports. '
                'Always consult with your veterinarian before starting, stopping, or modifying any medication regimen. '
                'This tool is for tracking purposes only and does not replace professional veterinary advice.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 40,
                child: TextButton.icon(
                  onPressed: () {
                    _exportMedicationLog(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF75ACFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  icon: const Icon(Icons.file_download,
                      color: AppColors.burgundy, size: 16),
                  label: Text(
                    l10n.exportMedicationLog,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.burgundy,
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

class _MeasurementHistory extends StatefulWidget {
  const _MeasurementHistory({required this.onExport});

  final VoidCallback onExport;

  @override
  State<_MeasurementHistory> createState() => _MeasurementHistoryState();
}

class _MeasurementHistoryState extends State<_MeasurementHistory> {
  String? _selectedPeriod;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final periodOptions = [
      l10n.last24Hours,
      l10n.last3Days,
      l10n.last7Days,
      l10n.last30Days,
      l10n.last90Days,
      l10n.customRange,
    ];
    _selectedPeriod ??= l10n.last7Days;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.measurementHistory, style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        const Text('Princess • 7 recordings', style: AppTextStyles.body),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  style: AppTextStyles.body,
                  items: periodOptions
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPeriod = value);
                    }
                  },
                ),
              ),
            ),
            _FilterChipButton(
              label: l10n.exportLabel,
              onTap: widget.onExport,
              icon: Icons.file_download,
              filled: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          child: Column(
            children: [
              Row(
                children: [
                  _StatCard(title: l10n.averageSrr, value: '31', footnote: l10n.bpm),
                  const SizedBox(width: 8),
                  _StatCard(title: l10n.range, value: '29-33', footnote: l10n.minMax),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatCard(title: l10n.trend, value: '+2', footnote: l10n.bpmChange),
                  const SizedBox(width: 8),
                  const _StatusCard(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.srrOverTime,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              const _BadgeRow(),
              const SizedBox(height: 8),
              const _BadgeRowSecond(),
              const SizedBox(height: 16),
              const _SrrChart(),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF75ACFF) : AppColors.offWhite,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.burgundy),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTextStyles.body),
            if (!filled) ...[
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendBadge(
          color: Color(0xFF75ACFF),
          label: 'Normal (<30)',
        ),
        SizedBox(width: 8),
        _LegendBadge(
          color: Color(0xFFFFE476),
          label: 'Elevated (30-40)',
        ),
      ],
    );
  }
}

class _BadgeRowSecond extends StatelessWidget {
  const _BadgeRowSecond();

  @override
  Widget build(BuildContext context) {
    return const _LegendBadge(
      color: Color(0xFFE64E60),
      label: 'Alert (>40)',
    );
  }
}

class _LegendBadge extends StatelessWidget {
  const _LegendBadge({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.burgundy)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.footnote,
  });

  final String title;
  final String value;
  final String footnote;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 109,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.caption.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.heading2.copyWith(fontSize: 24),
                ),
                const Spacer(),
                Text(footnote, style: AppTextStyles.caption.copyWith(fontSize: 12)),
              ],
            ),
            const Positioned(
              right: 8,
              top: 8,
              child: Icon(Icons.notifications_none,
                  size: 18, color: AppColors.burgundy),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: Container(
        height: 109,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.status, style: AppTextStyles.caption.copyWith(fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatusPill(value: '1', color: Color(0xFF75ACFF)),
                const SizedBox(width: 8),
                _StatusPill(value: '6', color: Color(0xFFFFE476)),
                const SizedBox(width: 8),
                _StatusPill(value: '0', color: Color(0xFFE64E60), muted: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.value,
    required this.color,
    this.muted = false,
  });

  final String value;
  final Color color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 27,
          height: 2,
          decoration: BoxDecoration(
            color: muted ? color.withOpacity(0.4) : color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _SrrChart extends StatelessWidget {
  const _SrrChart();

  @override
  Widget build(BuildContext context) {
    final data = [
      _SrrPoint('Jan 3', 28),
      _SrrPoint('Jan 4', 29),
      _SrrPoint('Jan 5', 31),
      _SrrPoint('Jan 6', 35),
      _SrrPoint('Jan 7', 33),
      _SrrPoint('Jan 8', 30),
      _SrrPoint('Jan 9', 32),
    ];

    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.zero,
        primaryXAxis: CategoryAxis(
          axisLine: const AxisLine(width: 1, color: AppColors.burgundy),
          majorGridLines: const MajorGridLines(
            width: 0.5,
            color: Color(0xFFE0E0E0),
            dashArray: [3, 3],
          ),
          majorTickLines: const MajorTickLines(size: 6, width: 1),
          labelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.burgundy,
            fontSize: 10,
          ),
          labelRotation: 0,
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 50,
          interval: 10,
          axisLine: const AxisLine(width: 1, color: AppColors.burgundy),
          majorTickLines: const MajorTickLines(size: 6, width: 1),
          majorGridLines: const MajorGridLines(
            width: 0.5,
            color: Color(0xFFE0E0E0),
            dashArray: [3, 3],
          ),
          labelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.burgundy,
            fontSize: 10,
          ),
          plotBands: [
            PlotBand(
              start: 30,
              end: 30,
              borderColor: AppColors.burgundy,
              borderWidth: 1,
              dashArray: const [4, 4],
              text: 'Normal Threshold (30 BPM)',
              textStyle:
                  AppTextStyles.caption.copyWith(color: AppColors.burgundy),
              horizontalTextAlignment: TextAnchor.end,
              verticalTextAlignment: TextAnchor.middle,
            ),
            PlotBand(
              start: 40,
              end: 40,
              borderColor: AppColors.burgundy,
              borderWidth: 1,
              dashArray: const [4, 4],
              text: 'Alert Threshold (40 BPM)',
              textStyle:
                  AppTextStyles.caption.copyWith(color: AppColors.burgundy),
              horizontalTextAlignment: TextAnchor.end,
              verticalTextAlignment: TextAnchor.middle,
            ),
          ],
        ),
        series: [
          AreaSeries<_SrrPoint, String>(
            dataSource: data,
            xValueMapper: (_SrrPoint point, _) => point.label,
            yValueMapper: (_SrrPoint point, _) => point.value,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x40146FD9),
                Color(0x00146FD9),
              ],
            ),
            borderColor: const Color(0xFF146FD9),
            borderWidth: 2,
            markerSettings: const MarkerSettings(
              isVisible: true,
              width: 8,
              height: 8,
              color: Color(0xFF146FD9),
              borderWidth: 2,
              borderColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SrrPoint {
  const _SrrPoint(this.label, this.value);

  final String label;
  final double value;
}

class _AddMedicationSheet extends StatefulWidget {
  const _AddMedicationSheet();

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  bool _remindersEnabled = false;
  String _frequency = 'Once daily';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      Text(l10n.addNewMedication, style: AppTextStyles.heading2),
                      const SizedBox(height: 8),
                      Text(
                        'Record a new medication or treatment for Princess’ care plan',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _FormField(label: l10n.medicationNameRequired, hint: 'e.g., Pimobendan'),
                const SizedBox(height: 16),
                _FormField(label: l10n.dosageRequired, hint: 'e.g., 5mg'),
                const SizedBox(height: 16),
                _DropdownField(
                  label: l10n.frequencyRequired,
                  value: _frequency,
                  onChanged: (value) =>
                      setState(() => _frequency = value ?? _frequency),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(label: l10n.startDateRequired, hint: ''),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FormField(
                        label: l10n.endDateOptional,
                        hint: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormField(label: l10n.prescribedBy, hint: 'e.g., Dr. Smith, DVM'),
                const SizedBox(height: 16),
                _FormField(
                  label: l10n.purposeCondition,
                  hint: 'e.g., Congestive Heart Failure',
                ),
                const SizedBox(height: 16),
                _TextArea(
                  label: l10n.additionalNotes,
                  hint:
                      'Any special instructions, side effects to monitor, or additional information...',
                ),
                const SizedBox(height: 16),
                _ReminderCard(
                  enabled: _remindersEnabled,
                  onChanged: (value) =>
                      setState(() => _remindersEnabled = value),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.offWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF146FD9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        l10n.addMedication,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.offWhite,
              hintText: hint,
              hintStyle:
                  AppTextStyles.body.copyWith(color: AppColors.burgundy.withOpacity(0.3)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: const [
                DropdownMenuItem(value: 'Once daily', child: Text('Once daily')),
                DropdownMenuItem(value: 'Twice daily', child: Text('Twice daily')),
                DropdownMenuItem(value: 'As needed', child: Text('As needed')),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _TextArea extends StatelessWidget {
  const _TextArea({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.offWhite,
            hintText: hint,
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.burgundy.withOpacity(0.3)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_none, color: AppColors.burgundy),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicationReminders,
                    style:
                        AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    l10n.medicationRemindersDesc,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeColor: AppColors.burgundy,
          ),
        ],
      ),
    );
  }
}
