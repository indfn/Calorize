import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/utils/macro_calculator.dart';
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
                double weightToSave = isMetric ? enteredValue : enteredValue / 2.20462;

                await DatabaseService().logWeight(weightToSave);
                if (mounted) {
                  Navigator.pop(context);
                  await _loadData();
                  _checkGoalReached();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkGoalReached() async {
    if (_userProfile == null || _userProfile!.targetWeight == null) return;

    final profile = _userProfile!;
    final currentWeight = profile.weight ?? 0;
    final targetWeight = profile.targetWeight!;
    final goalType = profile.goalType;

    bool reached = false;
    if (goalType == 'lose') {
      reached = currentWeight <= targetWeight;
    } else if (goalType == 'gain') {
      reached = currentWeight >= targetWeight;
    } else if (goalType == 'maintain') {
      reached = (currentWeight - targetWeight).abs() <= 0.5;
    }

    if (reached && mounted) {
      _showGoalReachedDialog();
    }
  }

  void _showGoalReachedDialog() {
    final profile = _userProfile!;
    final isMetric = profile.isMetric ?? true;
    final currentWeight = profile.weight ?? 0;
    final unit = isMetric ? 'kg' : 'lbs';
    final displayWeight = isMetric ? currentWeight : currentWeight * 2.20462;

    showDialog(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(
            '🎉 Goal Reached!',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Amazing work! You've reached your target weight of ${displayWeight.toStringAsFixed(1)} $unit!",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'What would you like to do next?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGoalOption(
                  scheme: scheme,
                  icon: Icons.flag_outlined,
                  iconColor: Colors.blue,
                  title: 'Continue Current Plan',
                  description: 'Keep your current goal type. No changes to your targets.',
                  onTap: () => Navigator.pop(ctx),
                ),
                const SizedBox(height: 12),
                _buildGoalOption(
                  scheme: scheme,
                  icon: Icons.balance_outlined,
                  iconColor: Colors.green,
                  title: 'Switch to Maintain',
                  description: 'Set your goal to maintain your current weight.',
                  onTap: () => _switchGoal(ctx, 'maintain', currentWeight),
                ),
                const SizedBox(height: 12),
                _buildGoalOption(
                  scheme: scheme,
                  icon: Icons.trending_up_outlined,
                  iconColor: Colors.orange,
                  title: 'Switch to Gain',
                  description: 'Set a new goal to build muscle and gain weight.',
                  onTap: () => _switchGoal(ctx, 'gain', currentWeight),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(bottom: 8),
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalOption({
    required ColorScheme scheme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchGoal(BuildContext ctx, String newGoalType, double currentWeight) async {
    final db = DatabaseService();
    final profile = await db.getUserProfile();
    if (profile == null) return;

    profile.goalType = newGoalType;
    if (newGoalType == 'maintain') {
      profile.targetWeight = currentWeight;
    } else if (newGoalType == 'gain') {
      profile.targetWeight = currentWeight + 3.0;
    }

    // Recalculate TDEE for the new goal type
    if (profile.dob != null &&
        profile.weight != null &&
        profile.height != null &&
        profile.gender != null &&
        profile.activityLevel != null) {
      final age = MacroCalculator.calculateAge(profile.dob!);
      final bmr = MacroCalculator.calculateBMR(
        weightKg: profile.weight!,
        heightCm: profile.height!,
        age: age,
        gender: profile.gender!,
      );
      final tdee = MacroCalculator.calculateTDEE(
        bmr: bmr,
        activityLevel: profile.activityLevel!,
      );
      profile.tdeeGoal = MacroCalculator.calculateDailyTarget(
        tdee: tdee,
        goalType: newGoalType,
        weightLossRate: profile.weightLossRate ?? 0.5,
      );
    }

    await db.isar.writeTxn(() async {
      await db.isar.userProfiles.put(profile);
    });

    if (mounted) {
      Navigator.pop(ctx);
      _loadData();
    }
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
