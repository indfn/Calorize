import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/data/models/daily_stat.dart';
import 'package:calorize/widgets/progress/weight_card.dart';
import 'package:calorize/widgets/progress/streak_card.dart';

import 'package:calorize/widgets/progress/weight_chart.dart';
import 'package:calorize/widgets/progress/calorie_chart.dart';
import 'package:calorize/widgets/progress/bmi_card.dart';
import 'package:calorize/widgets/progress/food_history_list.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  UserProfile? _userProfile;
  int _streak = 0;
  List<DailyStat> _weeklyStats = [];
  List<DailyStat> _weightHistory = [];
  List<DailyStat> _calorieHistory = [];
  String _selectedRange = '90 Days';
  String _calorieChartRange = '7 Days';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await DatabaseService().getUserProfile();
    final streak = await DatabaseService().getCurrentStreak();
    final stats = await DatabaseService().getWeeklyStats();
    final weightHistory = await DatabaseService().getWeightHistory(90);
    
    // Fetch calorie history based on selected range
    int calorieDays = _calorieChartRange == '7 Days' ? 7 : (_calorieChartRange == 'Month' ? 30 : 365);
    final calorieHistory = await DatabaseService().getCalorieHistory(calorieDays);
    
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _streak = streak;
        _weeklyStats = stats;
        _weightHistory = weightHistory;
        _calorieHistory = calorieHistory;
      });
    }
  }

  void _logWeight() {
    showDialog(
      context: context,
      builder: (context) {
        final isMetric = _userProfile?.isMetric ?? true;
        double currentWeightKg = _userProfile?.weight ?? 0;
        
        // Initial display value
        double displayWeight = isMetric ? currentWeightKg : currentWeightKg * 2.20462;
        
        // Value to save (starts as display value)
        double enteredValue = displayWeight;

        return AlertDialog(
          title: Text('Log Weight (${isMetric ? 'kg' : 'lbs'})'),
          content: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Weight',
              suffixText: isMetric ? 'kg' : 'lbs',
            ),
            controller: TextEditingController(text: displayWeight.toStringAsFixed(1)),
            onChanged: (value) {
              enteredValue = double.tryParse(value) ?? enteredValue;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                // Convert back to KG if needed
                double weightToSave = isMetric ? enteredValue : enteredValue / 2.20462;
                
                await DatabaseService().logWeight(weightToSave);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData(); // Refresh
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: WeightCard(
                      userProfile: _userProfile,
                      onLogWeight: _logWeight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StreakCard(
                      streakCount: _streak,
                      weeklyStats: _weeklyStats,
                      userProfile: _userProfile,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Time Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['90 Days', '6 Months', '1 Year', 'All time'].map((range) {
                    final isSelected = _selectedRange == range;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedRange = range);
                          // Logic to fetch different range would go here
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: Theme.of(context).shadowColor.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ] : null,
                          ),
                          child: Text(
                            range,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              // Weight Chart
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: WeightChart(
                  stats: _weightHistory,
                  goalWeight: _userProfile?.targetWeight ?? 0,
                  isMetric: _userProfile?.isMetric ?? true,
                ),
              ),
              const SizedBox(height: 24),
              // Calorie Chart
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calorie Chart Time Selector
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['7 Days', 'Month', 'Lifetime'].map((range) {
                          final isSelected = _calorieChartRange == range;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _calorieChartRange = range);
                                _loadData(); // Reload with new range
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  range,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CalorieChart(
                      stats: _calorieHistory,
                      calorieGoal: _userProfile?.getTdeeGoalForDay(DateTime.now().weekday) ?? 2000,
                      selectedRange: _calorieChartRange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BmiCard(userProfile: _userProfile),
              const SizedBox(height: 24),
              const FoodHistoryList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
