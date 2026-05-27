import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/daily_stat.dart';
import 'package:intl/intl.dart';

class CalorieChart extends StatelessWidget {
  final List<DailyStat> stats;
  final int calorieGoal;
  final String selectedRange; // '7 Days', 'Month', 'Lifetime'

  const CalorieChart({
    super.key,
    required this.stats,
    required this.calorieGoal,
    required this.selectedRange,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: Text('No calorie data available', style: GoogleFonts.inter(color: Theme.of(context).disabledColor)),
      );
    }

    // Calculate total calories for display (sum of visible range or average?)
    // User request: "Total calories... 0.0 cals" (maybe average or total for the day?)
    // The previous design showed "Total calories" as a header.
    // Let's show the average for the period.
    double totalCals = 0;
    for (var s in stats) totalCals += s.totalCalories;
    double avgCals = stats.isEmpty ? 0 : totalCals / stats.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avg Calories:',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${avgCals.toInt()} cals',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Legend for 7 Days view
            if (selectedRange == '7 Days')
              Row(
                children: [
                  _buildLegendItem(context, Colors.orange, 'Protein'),
                  const SizedBox(width: 8),
                  _buildLegendItem(context, Colors.blue, 'Carbs'),
                  const SizedBox(width: 8),
                  _buildLegendItem(context, Colors.yellow, 'Fat'),
                ],
              ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: selectedRange == '7 Days' 
            ? _buildStackedBarChart(context) 
            : _buildLineChart(context),
        ),
      ],
    );
  }


  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color)),
      ],
    );
  }


  Widget _buildStackedBarChart(BuildContext context) {
    // Ensure we have 7 days of data, pad if needed? 
    // Or just show what we have.
    // We should map stats to days of week.
    
    // Calculate max value from data, then round up to nearest 500
    double maxCalories = 0;
    for (var stat in stats) {
      final protein = stat.totalProtein;
      final carbs = stat.totalCarbs;
      final fat = stat.totalFat;
      final totalCals = (protein * 4) + (carbs * 4) + (fat * 9);
      if (totalCals > maxCalories) maxCalories = totalCals;
    }
    
    // Round up to nearest 500
    final maxY = ((maxCalories / 500).ceil() * 500).toDouble();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Theme.of(context).colorScheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= 0 && groupIndex < stats.length) {
                final stat = stats[groupIndex];
                final protein = stat.totalProtein;
                final carbs = stat.totalCarbs;
                final fat = stat.totalFat;
                final totalCals = stat.totalCalories;
                
                // Show all macros in tooltip
                return BarTooltipItem(
                  '',
                  TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
                  children: [
                    TextSpan(
                      text: 'Total: ${totalCals.toInt()} cal\n',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: 'Protein: ${protein.toInt()}g (${(protein * 4).toInt()} cal)\n',
                      style: const TextStyle(color: Colors.orange, fontSize: 10),
                    ),
                    TextSpan(
                      text: 'Carbs: ${carbs.toInt()}g (${(carbs * 4).toInt()} cal)\n',
                      style: const TextStyle(color: Colors.blue, fontSize: 10),
                    ),
                    TextSpan(
                      text: 'Fat: ${fat.toInt()}g (${(fat * 9).toInt()} cal)',
                      style: const TextStyle(color: Colors.yellow, fontSize: 10),
                    ),
                  ],
                );
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < stats.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(stats[value.toInt()].date).substring(0, 1),
                      style: GoogleFonts.inter(color: Theme.of(context).disabledColor, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 500,
              getTitlesWidget: (value, meta) {
                // Only show labels at clean 500 intervals
                if (value % 500 == 0) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.inter(
                      color: Theme.of(context).disabledColor,
                      fontSize: 10,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1, dashArray: [5, 5]),
        ),
        borderData: FlBorderData(show: false),
        barGroups: stats.asMap().entries.map((e) {
          final index = e.key;
          final stat = e.value;
          final protein = stat.totalProtein;
          final carbs = stat.totalCarbs;
          final fat = stat.totalFat;
          
          // Calculate calories from each macro
          final fatCals = fat * 9;
          final carbsCals = carbs * 4;
          final proteinCals = protein * 4;
          final totalCals = fatCals + carbsCals + proteinCals;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: totalCals, // Height = total calories (not grams!)
                rodStackItems: [
                  BarChartRodStackItem(0, fatCals, Colors.yellow),
                  BarChartRodStackItem(fatCals, fatCals + carbsCals, Colors.blue),
                  BarChartRodStackItem(fatCals + carbsCals, totalCals, Colors.orange),
                ],
                color: Colors.transparent,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    // Determine min/max
    double maxCals = 0;
    for (var s in stats) {
      final val = s.totalCalories.toDouble();
      if (val > maxCals) maxCals = val;
    }
    maxCals += 500; // Padding

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false), // Minimalist for trend? Or show dates?
        // User said "like the weight progress chart". So show grid and axis?
        // Let's keep it simple for now, maybe just the line.
        // Actually, dates on bottom are useful.
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (stats.length - 1).toDouble(),
        minY: 0,
        maxY: maxCals,
        lineBarsData: [
          LineChartBarData(
            spots: stats.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.totalCalories.toDouble());
            }).toList(),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(
      show: true,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
    ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < stats.length) {
                  final date = stats[index].date;
                  return LineTooltipItem(
                    '${DateFormat('MMM d').format(date)}\n',
                    TextStyle(color: Theme.of(context).colorScheme.onInverseSurface.withValues(alpha: 0.7), fontSize: 10),
                    children: [
                      TextSpan(
                        text: '${spot.y.toInt()} cals',
                        style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
