import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/data/models/macro_goal.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/widgets/macro_edit_popup.dart';

const List<String> _dayAbbr = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
const List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<Color> _barColors = [
  Color(0xFFE57373),
  Color(0xFFFFB74D),
  Color(0xFFFFF176),
  Color(0xFF81C784),
  Color(0xFF64B5F6),
  Color(0xFFBA68C8),
  Color(0xFF4DB6AC),
];

class WeeklyMacrosScreen extends StatefulWidget {
  final UserProfile profile;

  const WeeklyMacrosScreen({super.key, required this.profile});

  @override
  State<WeeklyMacrosScreen> createState() => _WeeklyMacrosScreenState();
}

class _WeeklyMacrosScreenState extends State<WeeklyMacrosScreen> {
  late UserProfile _profile;
  bool _constantGoals = true;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _constantGoals = _profile.weeklyGoals == null || _profile.weeklyGoals!.isEmpty;
  }

  Future<void> _reloadProfile() async {
    final profile = await DatabaseService().getUserProfile();
    if (profile != null && mounted) {
      setState(() => _profile = profile);
    }
  }

  void _openEditPopup(int day) {
    showDialog(
      context: context,
      builder: (_) => MacroEditPopup(
        profile: _profile,
        initialDay: day,
        onSaved: _reloadProfile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Macros')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SwitchListTile(
              title: const Text('Constant Calorie Goals'),
              subtitle: const Text('Same goals for every day'),
              value: _constantGoals,
              onChanged: (val) async {
                setState(() => _constantGoals = val);
                if (val) {
                  final base = _profile.getGoalForDay(1);
                  if (base != null) {
                    await DatabaseService().applyConstantGoals(base);
                  } else {
                    await DatabaseService().applyConstantGoals(
                      MacroGoal()
                        ..dayOfWeek = 1
                        ..tdeeGoal = _profile.getTdeeGoalForDay(1)
                        ..proteinGoal = _profile.getProteinGoalForDay(1)
                        ..carbsGoal = _profile.getCarbsGoalForDay(1)
                        ..fatGoal = _profile.getFatGoalForDay(1),
                    );
                  }
                  await _reloadProfile();
                } else {
                  await DatabaseService().clearWeeklyGoals();
                  await _reloadProfile();
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2E2E2E) : Colors.grey.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Calorie Goals',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap a bar to customize goals for that day',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _maxCalories(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Theme.of(context).colorScheme.inverseSurface,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final day = group.x.toInt();
                            final protein = _profile.getProteinGoalForDay(day);
                            final carbs = _profile.getCarbsGoalForDay(day);
                            final fat = _profile.getFatGoalForDay(day);
                            final total = (protein * 4) + (carbs * 4) + (fat * 9);
                            return BarTooltipItem(
                              '${_dayNames[day - 1]}\n',
                              TextStyle(
                                color: Theme.of(context).colorScheme.onInverseSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Total: ${total.round()} cal\n',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onInverseSurface,
                                    fontSize: 11,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Protein: ', style: TextStyle(color: Colors.orange, fontSize: 10),
                                ),
                                TextSpan(
                                  text: '${protein.round()}g\n',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontSize: 10),
                                ),
                                const TextSpan(
                                  text: 'Carbs: ', style: TextStyle(color: Colors.blue, fontSize: 10),
                                ),
                                TextSpan(
                                  text: '${carbs.round()}g\n',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontSize: 10),
                                ),
                                const TextSpan(
                                  text: 'Fat: ', style: TextStyle(color: Colors.yellow, fontSize: 10),
                                ),
                                TextSpan(
                                  text: '${fat.round()}g',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontSize: 10),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 500,
                            getTitlesWidget: (value, meta) {
                              if (value % 500 == 0) {
                                return Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.inter(
                                    color: textSecondary,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt() - 1;
                              if (idx < 0 || idx >= 7) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _dayAbbr[idx],
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: idx == DateTime.now().weekday - 1
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: idx == DateTime.now().weekday - 1
                                        ? Theme.of(context).colorScheme.primary
                                        : textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 500,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark ? Colors.white12 : Colors.black12,
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          );
                        },
                      ),
                      barGroups: List.generate(7, (i) {
                        final day = i + 1;
                        final proteinGrams = _profile.getProteinGoalForDay(day);
                        final carbsGrams = _profile.getCarbsGoalForDay(day);
                        final fatGrams = _profile.getFatGoalForDay(day);
                        final proteinCals = proteinGrams * 4;
                        final carbsCals = carbsGrams * 4;
                        final fatCals = fatGrams * 9;
                        final totalCals = proteinCals + carbsCals + fatCals;
                        final isToday = day == DateTime.now().weekday;

                        return BarChartGroupData(
                          x: day,
                          barRods: [
                            BarChartRodData(
                              toY: totalCals,
                              rodStackItems: [
                                BarChartRodStackItem(0, fatCals, const Color(0xFFFFD700)),
                                BarChartRodStackItem(fatCals, fatCals + carbsCals, const Color(0xFF4CAF50)),
                                BarChartRodStackItem(fatCals + carbsCals, totalCals, const Color(0xFFFF9800)),
                              ],
                              color: Colors.transparent,
                              width: isToday ? 20 : 14,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }),
                    ),
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem('P', const Color(0xFFFF9800), textSecondary),
                    const SizedBox(width: 16),
                    _legendItem('C', const Color(0xFF4CAF50), textSecondary),
                    const SizedBox(width: 16),
                    _legendItem('F', const Color(0xFFFFD700), textSecondary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDayDetailCards(),
        ],
      ),
    );
  }

  double _maxCalories() {
    double max = 0;
    for (int day = 1; day <= 7; day++) {
      final protein = _profile.getProteinGoalForDay(day) * 4;
      final carbs = _profile.getCarbsGoalForDay(day) * 4;
      final fat = _profile.getFatGoalForDay(day) * 9;
      final total = protein + carbs + fat;
      if (total > max) max = total;
    }
    return ((max / 500).ceil() * 500).toDouble();
  }

  Widget _legendItem(String label, Color color, Color textSecondary) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
        ),
      ],
    );
  }

  Widget _buildDayDetailCards() {
    return Column(
      children: List.generate(7, (i) {
        final day = i + 1;
        final isToday = day == DateTime.now().weekday;
        final goal = _profile.getTdeeGoalForDay(day);
        final protein = _profile.getProteinGoalForDay(day).round();
        final carbs = _profile.getCarbsGoalForDay(day).round();
        final fat = _profile.getFatGoalForDay(day).round();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openEditPopup(day),
            child: _buildDayCard(day, goal, protein, carbs, fat, isToday),
          ),
        );
      }),
    );
  }

  Widget _buildDayCard(int day, int goal, int protein, int carbs, int fat, bool isToday) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
            : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : isDark
                  ? const Color(0xFF2E2E2E)
                  : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _barColors[day - 1],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dayNames[day - 1],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                'P ${protein}g | C ${carbs}g | F ${fat}g',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$goal',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'cal',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 20, color: textSecondary),
        ],
      ),
    );
  }
}
