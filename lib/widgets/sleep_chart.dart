import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/sleep_calculator.dart';

class SleepChartPoint {
  final String label;
  final int durationMinutes;

  const SleepChartPoint({
    required this.label,
    required this.durationMinutes,
  });
}

class SleepChart extends StatelessWidget {
  final List<SleepChartPoint> points;
  final bool isDark;

  const SleepChart({
    super.key,
    required this.points,
    required this.isDark,
  });

  Color _getSpotColor(double hours) {
    if (hours < 7)
      return isDark ? AppColors.badSleepDark : AppColors.badSleepLight;
    if (hours <= 8)
      return isDark
          ? AppColors.excellentSleepDark
          : AppColors.excellentSleepLight;
    return isDark ? AppColors.overSleepDark : AppColors.overSleepLight;
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final gridColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    // Build spots
    final spots = <FlSpot>[];
    for (int i = 0; i < points.length; i++) {
      final hours = SleepCalculator.durationInHours(points[i].durationMinutes);
      spots.add(FlSpot(i.toDouble(), double.parse(hours.toStringAsFixed(1))));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 24,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 4,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: textColor, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= points.length) return const SizedBox();
                final label = points[idx].label;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(color: textColor, fontSize: 11),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: primaryColor,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final hours = spot.y;
                final color = _getSpotColor(hours);
                return FlDotCirclePainter(
                  radius: 5,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withOpacity(0.08),
            ),
          ),
          // Excellent sleep zone band (7-8h)
          LineChartBarData(
            spots: points
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), 7))
                .toList(),
            isCurved: false,
            color: (isDark
                    ? AppColors.excellentSleepDark
                    : AppColors.excellentSleepLight)
                .withOpacity(0.3),
            barWidth: 0,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            aboveBarData: BarAreaData(
              show: true,
              cutOffY: 8,
              applyCutOffY: true,
              color: (isDark
                      ? AppColors.excellentSleepDark
                      : AppColors.excellentSleepLight)
                  .withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }
}
