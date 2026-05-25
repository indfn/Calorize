import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/daily_stat.dart';

class WeightChart extends StatelessWidget {
  final List<DailyStat> stats;
  final double goalWeight;
  final bool isMetric;

  const WeightChart({
    super.key,
    required this.stats,
    required this.goalWeight,
    required this.isMetric,
  });

  @override
  Widget build(BuildContext context) {
    // Filter stats with weight entries
    final weightStats = stats.where((s) => s.weightEntry != null && s.weightEntry! > 0).toList();
    
    if (weightStats.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text('No weight data available', style: GoogleFonts.inter(color: Theme.of(context).disabledColor)),
      );
    }

    // Convert values if Imperial
    final double conversionFactor = isMetric ? 1.0 : 2.20462;
    final double displayGoal = goalWeight * conversionFactor;
    
    // Determine min/max Y for chart scaling
    double minWeight = displayGoal;
    double maxWeight = displayGoal;
    
    for (var s in weightStats) {
      final val = s.weightEntry! * conversionFactor;
      if (val < minWeight) minWeight = val;
      if (val > maxWeight) maxWeight = val;
    }
    
    // Add padding
    minWeight -= 1;
    maxWeight += 1;

    // Dynamic interval based on range
    double range = maxWeight - minWeight;
    double interval = 1.0;
    if (range > 20) interval = 5.0;
    else if (range > 10) interval = 2.0;
    else if (range < 2) interval = 0.5;

    // Align min/max to interval
    minWeight = (minWeight / interval).floor() * interval;
    maxWeight = (maxWeight / interval).ceil() * interval;
    
    // Add one interval padding if range is too tight (optional, but good for visuals)
    if (maxWeight == minWeight) {
        minWeight -= interval;
        maxWeight += interval;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Progress',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      if (value == minWeight || value == maxWeight) return const SizedBox();
                      
                      // Format label: Remove .0 if integer
                      String text = value.toStringAsFixed(1);
                      if (text.endsWith('.0')) {
                        text = text.substring(0, text.length - 2);
                      }
                      
                      return Text(
                        text,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).disabledColor,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (weightStats.length - 1).toDouble(),
              minY: minWeight,
              maxY: maxWeight,
              lineBarsData: [
                // Goal Line
                LineChartBarData(
                  spots: [
                    FlSpot(0, displayGoal),
                    FlSpot((weightStats.length - 1).toDouble(), displayGoal),
                  ],
                  isCurved: false,
                  color: Theme.of(context).dividerColor,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  dashArray: [5, 5],
                ),
                // Weight Trend
                LineChartBarData(
                  spots: weightStats.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.weightEntry! * conversionFactor);
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: Theme.of(context).colorScheme.surface,
                      );
                    },
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((spotIndex) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: Theme.of(context).disabledColor,
                        strokeWidth: 1,
                        dashArray: [5, 5], // Or solid if they want "straight"
                      ),
                      FlDotData(show: false), // Hide the touch dot (we have permanent dots)
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      // Only show tooltip for the weight trend line (barIndex 1)
                      if (spot.barIndex != 1) return null;

                      return LineTooltipItem(
                        spot.y.toStringAsFixed(1),
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
