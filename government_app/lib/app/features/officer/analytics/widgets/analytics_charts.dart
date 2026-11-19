import 'package:material_ui/material_ui.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';

/// Reusable, backend-driven charts for the officer Reports & Analytics screen.
/// All values are supplied by ReportsScreen; this widget contains no mock data.
class AnalyticsCharts extends StatelessWidget {
  final int malePopulation;
  final int femalePopulation;
  final int completedScreenings;
  final int inProgressScreenings;
  final List<MapEntry<String, int>> monthlyCounts;
  final Map<String, int> areaCounts;
  final Map<String, Map<String, int>> workerPerformance;
  final int pendingReferrals;
  final int scheduledReferrals;
  final int completedReferrals;

  const AnalyticsCharts({
    super.key,
    required this.malePopulation,
    required this.femalePopulation,
    required this.completedScreenings,
    required this.inProgressScreenings,
    required this.monthlyCounts,
    required this.areaCounts,
    required this.workerPerformance,
    required this.pendingReferrals,
    required this.scheduledReferrals,
    required this.completedReferrals,
  });

  static const Color _blue = Color(0xFF2563EB);
  static const Color _teal = Color(0xFF0D9488);
  static const Color _green = Color(0xFF16A34A);
  static const Color _amber = Color(0xFFD97706);
 

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('VISUAL ANALYTICS', 'Programme charts'),
        const SizedBox(height: 12),
        _chartCard(
          'POPULATION DISTRIBUTION',
          'Registered population by gender',
          _populationChart(),
          _legend([
            _LegendItem('Male', _blue, malePopulation),
            _LegendItem('Female', _teal, femalePopulation),
          ]),
        ),
        const SizedBox(height: 14),
        _chartCard(
          'SCREENING STATUS',
          'Screening records by status',
          _screeningChart(),
          _legend([
            _LegendItem('Completed', _green, completedScreenings),
            _LegendItem('In progress', _amber, inProgressScreenings),
          ]),
        ),
        const SizedBox(height: 14),
        _chartCard(
          'MONTHLY TREND',
          'Screening volume over time',
          _monthlyChart(),
          const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        _chartCard(
          'AREA ACTIVITY',
          'Screening records by worker area',
          _areaChart(),
          const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        _chartCard(
          'WORKER PERFORMANCE',
          'Total and completed screening records',
          _workerChart(),
          _legend([
            const _LegendItem('Total', _blue, null),
            const _LegendItem('Completed', _green, null),
          ]),
        ),
        const SizedBox(height: 14),
        _chartCard(
          'REFERRAL STATUS',
          'Referral records by status',
          _referralChart(),
          _legend([
            _LegendItem('Pending', _amber, pendingReferrals),
            _LegendItem('Scheduled', _teal, scheduledReferrals),
            _LegendItem('Completed', _green, completedReferrals),
          ]),
        ),
      ],
    );
  }

  Widget _heading(String label, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _chartCard(
    String label,
    String title,
    Widget chart,
    Widget legend,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          chart,
          if (legend is! SizedBox) ...[
            const SizedBox(height: 12),
            legend,
          ],
        ],
      ),
    );
  }

  Widget _populationChart() {
    final total = malePopulation + femalePopulation;
    if (total == 0) return _empty('No population distribution data available.');
    return SizedBox(
      height: 168,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 35,
                sections: [
                  if (malePopulation > 0)
                    PieChartSectionData(
                      value: malePopulation.toDouble(),
                      color: _blue,
                      radius: 42,
                      title: '$malePopulation',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (femalePopulation > 0)
                    PieChartSectionData(
                      value: femalePopulation.toDouble(),
                      color: _teal,
                      radius: 42,
                      title: '$femalePopulation',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Total people',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
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

  Widget _screeningChart() {
    final total = completedScreenings + inProgressScreenings;
    if (total == 0) return _empty('No screening status data available.');
    return SizedBox(
      height: 168,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 37,
                sections: [
                  if (completedScreenings > 0)
                    PieChartSectionData(
                      value: completedScreenings.toDouble(),
                      color: _green,
                      radius: 42,
                      title: '$completedScreenings',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (inProgressScreenings > 0)
                    PieChartSectionData(
                      value: inProgressScreenings.toDouble(),
                      color: _amber,
                      radius: 42,
                      title: '$inProgressScreenings',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Screening records',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
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

  Widget _monthlyChart() {
    if (monthlyCounts.isEmpty) {
      return _empty('No monthly screening data for this selection.');
    }

    final spots = <FlSpot>[
      for (var i = 0; i < monthlyCounts.length; i++)
        FlSpot(i.toDouble(), monthlyCounts[i].value.toDouble()),
    ];
    final maxY = monthlyCounts
        .map((entry) => entry.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return SizedBox(
      height: 190,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY < 2 ? 2 : maxY + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFFE9EEF5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxY < 4 ? 1 : null,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= monthlyCounts.length) {
                    return const SizedBox.shrink();
                  }
                  final label = monthlyCounts[index].key.split(' ').first;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: _blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: _blue.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _areaChart() {
    final entries = areaCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) return _empty('No worker-area activity is available.');

    return SizedBox(
      height: _barChartHeight(entries.length),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _maxBarValue(entries.map((e) => e.value)),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFFE9EEF5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _shortLabel(entries[index].key),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value.toDouble(),
                    color: _blue,
                    width: _barWidth(entries.length),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _workerChart() {
    final entries = workerPerformance.entries.toList()
      ..sort((a, b) => b.value['total']!.compareTo(a.value['total']!));
    if (entries.isEmpty) return _empty('No worker-linked screening records.');

    return SizedBox(
      height: _barChartHeight(entries.length),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _maxBarValue(entries.map((e) => e.value['total']!)),
          groupsSpace: 16,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFFE9EEF5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _shortLabel(entries[index].key),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value['total']!.toDouble(),
                    color: _blue,
                    width: _barWidth(entries.length) * 0.48,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: entries[i].value['completed']!.toDouble(),
                    color: _green,
                    width: _barWidth(entries.length) * 0.48,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _referralChart() {
    final total = pendingReferrals + scheduledReferrals + completedReferrals;
    if (total == 0) return _empty('No referral status data available.');

    return SizedBox(
      height: 168,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 37,
                sections: [
                  if (pendingReferrals > 0)
                    PieChartSectionData(
                      value: pendingReferrals.toDouble(),
                      color: _amber,
                      radius: 42,
                      title: '$pendingReferrals',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (scheduledReferrals > 0)
                    PieChartSectionData(
                      value: scheduledReferrals.toDouble(),
                      color: _teal,
                      radius: 42,
                      title: '$scheduledReferrals',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (completedReferrals > 0)
                    PieChartSectionData(
                      value: completedReferrals.toDouble(),
                      color: _green,
                      radius: 42,
                      title: '$completedReferrals',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Referral records',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
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

  Widget _legend(List<_LegendItem> items) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: items.map((item) {
        final suffix = item.value == null ? '' : ' (${item.value})';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${item.label}$suffix',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _empty(String message) {
    return SizedBox(
      height: 76,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  double _maxBarValue(Iterable<int> values) {
    if (values.isEmpty) return 2;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    return maxValue < 2 ? 2 : maxValue + 1;
  }

  double _barChartHeight(int count) =>
      (count * 52.0 + 38).clamp(100.0, 300.0).toDouble();

  double _barWidth(int count) => count > 5 ? 12 : 22;

  String _shortLabel(String value) {
    if (value.length <= 11) return value;
    return '${value.substring(0, 10)}…';
  }
}

class _LegendItem {
  final String label;
  final Color color;
  final int? value;

  const _LegendItem(this.label, this.color, this.value);
}
