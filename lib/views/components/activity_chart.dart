import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../providers/config_provider.dart';

class ActivityChart extends ConsumerWidget {
  const ActivityChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(metricsProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Requests per minute (last 24h)',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          metricsAsync.when(
            data: (data) => _buildChart(data),
            loading: () => const AspectRatio(
              aspectRatio: 2,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => _buildChart([]), // Fallback with empty chart
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> data) {
    // Convert API data to spots
    List<FlSpot> spots;
    double maxY = 100;

    if (data.isEmpty) {
      // Flat line if no data
      spots = List.generate(12, (i) => FlSpot(i.toDouble(), 0));
    } else {
      // Take last 12 entries
      final recent = data.length > 12 ? data.sublist(data.length - 12) : data;
      spots = recent.asMap().entries.map((e) {
        final count = (e.value['count'] as num?)?.toDouble() ?? 0;
        return FlSpot(e.key.toDouble(), count);
      }).toList();
      final max = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      maxY = max < 10 ? 10 : max * 1.2;
    }

    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppTheme.dividerColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Label every other tick
                  if (value.toInt() % 2 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '-${(11 - value.toInt()) * 2}h',
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 4,
                maxIncluded: false,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
