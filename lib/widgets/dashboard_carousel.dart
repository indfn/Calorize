import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/widgets/stat_card.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/data/models/food_log.dart';
import 'package:calorize/data/models/daily_stat.dart';

class DashboardCarousel extends StatefulWidget {
  final UserProfile? userProfile;
  final List<FoodLog> todayLogs;
  final DailyStat? todayStat;

  const DashboardCarousel({
    super.key,
    this.userProfile,
    required this.todayLogs,
    this.todayStat,
  });

  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Calculate totals from today's stat (preferred) or logs
  int get _totalCalories => widget.todayStat?.totalCalories ?? 0;
  double get _totalProtein => widget.todayStat?.totalProtein ?? 0;
  double get _totalCarbs => widget.todayStat?.totalCarbs ?? 0;
  double get _totalFat => widget.todayStat?.totalFat ?? 0;
  
  // Micros still need to be calculated from logs as they aren't in DailyStat yet
  double get _totalFiber => widget.todayLogs.fold<double>(0, (sum, log) => sum + (log.macros.fiber ?? 0));
  double get _totalSugar => widget.todayLogs.fold<double>(0, (sum, log) => sum + (log.macros.sugar ?? 0));
  double get _totalSodium => widget.todayLogs.fold<double>(0, (sum, log) => sum + (log.macros.sodium ?? 0));

  // Calculate remaining values
  double get _fiberLeft {
    final weekday = DateTime.now().weekday;
    final goal = widget.userProfile?.getFiberGoalForDay(weekday) ?? 0;
    return goal - _totalFiber;
  }
  double get _sugarLeft {
    final weekday = DateTime.now().weekday;
    final goal = widget.userProfile?.getSugarGoalForDay(weekday) ?? 0;
    return goal - _totalSugar;
  }
  double get _sodiumLeft {
    final weekday = DateTime.now().weekday;
    final goal = widget.userProfile?.getSodiumGoalForDay(weekday) ?? 0;
    return goal - _totalSodium;
  }

  // Calculate progress (eaten / goal)
  double _calculateProgress(double eaten, double goal) {
    if (goal == 0) return 0.0;
    return (eaten / goal).clamp(0.0, 1.0);
  }

  // Calculate weeks remaining to reach target weight
  String _calculateWeeksRemaining() {
    final profile = widget.userProfile;
    if (profile == null || profile.targetWeight == null || profile.weight == null) {
      return '--';
    }

    final currentWeight = profile.weight!;
    final targetWeight = profile.targetWeight!;
    final weeklyPace = profile.weightLossRate ?? 0.5;

    if (weeklyPace <= 0) return '--';

    final weightDifference = (targetWeight - currentWeight).abs();
    if (weightDifference < 0.1) return '0'; // Already at target

    final weeksRemaining = (weightDifference / weeklyPace).ceil();
    return weeksRemaining.toString();
  }

  // Calculate Health Score (0-10)
  int _calculateHealthScore() {
    if (widget.userProfile == null) return 0;
    
    int score = 0;
    final weekday = DateTime.now().weekday;
    
    // 1. Calories (4 pts)
    final caloriesGoal = widget.userProfile!.getTdeeGoalForDay(weekday);
    if (caloriesGoal > 0 && _totalCalories > 0) {
      final ratio = _totalCalories / caloriesGoal;
      if (ratio >= 0.9 && ratio <= 1.1) {
        score += 4;
      } else if (ratio >= 0.8 && ratio <= 1.2) {
        score += 2;
      } else {
        score += 1;
      }
    }

    // 2. Protein (2 pts)
    final proteinGoal = widget.userProfile!.getProteinGoalForDay(weekday);
    if (proteinGoal > 0) {
      final ratio = _totalProtein / proteinGoal;
      if (ratio >= 0.9) {
        score += 2;
      } else if (ratio >= 0.7) {
        score += 1;
      }
    }

    // 3. Fiber (2 pts)
    final fiberGoal = widget.userProfile!.getFiberGoalForDay(weekday);
    if (fiberGoal > 0) {
      final ratio = _totalFiber / fiberGoal;
      if (ratio >= 0.9) {
        score += 2;
      } else if (ratio >= 0.7) {
        score += 1;
      }
    }

    // 4. Sugar & Sodium (2 pts)
    // Both below goal = 2 pts, one below = 1 pt
    final sugarGoal = widget.userProfile!.getSugarGoalForDay(weekday);
    final sodiumGoal = widget.userProfile!.getSodiumGoalForDay(weekday);
    
    int limitPoints = 0;
    if (_totalSugar <= sugarGoal) limitPoints++;
    if (_totalSodium <= sodiumGoal) limitPoints++;
    
    if (limitPoints == 2) score += 2;
    else if (limitPoints == 1) score += 1;

    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildNutritionPage(),
              _buildMicrosPage(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildNutritionPage() {
    final weekday = DateTime.now().weekday;
    final caloriesGoal = widget.userProfile?.getTdeeGoalForDay(weekday) ?? 2000;
    final proteinGoal = widget.userProfile?.getProteinGoalForDay(weekday) ?? 150;
    final carbsGoal = widget.userProfile?.getCarbsGoalForDay(weekday) ?? 250;
    final fatGoal = widget.userProfile?.getFatGoalForDay(weekday) ?? 65;
    
    // Calculate adjusted goal with rollover
    final isRolloverEnabled = widget.userProfile?.rolloverEnabled ?? false;
    final rollover = widget.todayStat?.rolloverFromPreviousDay ?? 0;
    
    // Safety check for rollover value
    final safeRollover = rollover.clamp(-1000, 1000); 
    
    final adjustedGoal = isRolloverEnabled 
        ? caloriesGoal + safeRollover.toInt()
        : caloriesGoal;
        
    final progress = (adjustedGoal > 0) ? (_totalCalories / adjustedGoal).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Large Calories Card
          Expanded(
            flex: 3,
            child: _buildCaloriesCard(adjustedGoal, caloriesGoal, progress, _totalCalories, isRolloverEnabled),
          ),
          const SizedBox(height: 16),
          // Macros Row
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Protein',
                    subtitle: (proteinGoal - _totalProtein) <= 0 ? null : 'left',
                    value: (proteinGoal - _totalProtein) <= 0 ? 'Criteria Met' : '${(proteinGoal - _totalProtein).toInt()}g',
                    progress: (proteinGoal > 0) ? (_totalProtein / proteinGoal).clamp(0.0, 1.0) : 0.0,
                    progressColor: const Color(0xFFE57373),
                    icon: Icons.restaurant,
                    iconColor: const Color(0xFFE57373),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Carbs',
                    subtitle: (carbsGoal - _totalCarbs) <= 0 ? null : 'left',
                    value: (carbsGoal - _totalCarbs) <= 0 ? 'Criteria Met' : '${(carbsGoal - _totalCarbs).toInt()}g',
                    progress: (carbsGoal > 0) ? (_totalCarbs / carbsGoal).clamp(0.0, 1.0) : 0.0,
                    progressColor: const Color(0xFFFFB74D),
                    icon: Icons.bakery_dining,
                    iconColor: const Color(0xFFFFB74D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Fats',
                    subtitle: (fatGoal - _totalFat) <= 0 ? null : 'left',
                    value: (fatGoal - _totalFat) <= 0 ? 'Criteria Met' : '${(fatGoal - _totalFat).toInt()}g',
                    progress: (fatGoal > 0) ? (_totalFat / fatGoal).clamp(0.0, 1.0) : 0.0,
                    progressColor: const Color(0xFF64B5F6),
                    icon: Icons.water_drop,
                    iconColor: const Color(0xFF64B5F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(int adjustedGoal, int baseGoal, double progress, int totalCalories, bool isRolloverEnabled) {
    final percentage = (progress * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isRolloverEnabled ? 'Adjusted Daily Goal:' : 'Daily Goal:',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    adjustedGoal.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(adjustedGoal - totalCalories) <= 0 ? 0 : adjustedGoal - totalCalories} left',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (isRolloverEnabled) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Base goal: $baseGoal',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Consumed:',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                '$totalCalories ($percentage%)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicrosPage() {
    final weekday = DateTime.now().weekday;
    final fiberGoal = widget.userProfile?.getFiberGoalForDay(weekday) ?? 38;
    final sugarGoal = widget.userProfile?.getSugarGoalForDay(weekday) ?? 50;
    final sodiumGoal = widget.userProfile?.getSodiumGoalForDay(weekday) ?? 2300;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Row of 3 Micros
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Fiber',
                    subtitle: _fiberLeft <= 0 ? null : 'left',
                    value: _fiberLeft <= 0 ? 'Criteria Met' : _fiberLeft.round().toString(),
                    unit: _fiberLeft <= 0 ? null : 'g',
                    progress: _calculateProgress(_totalFiber, fiberGoal),
                    progressColor: Colors.purple[300],
                    icon: Icons.grass,
                    iconColor: Colors.purple[300],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Sugar',
                    subtitle: _sugarLeft <= 0 ? null : 'left',
                    value: _sugarLeft <= 0 ? 'Criteria Met' : _sugarLeft.round().toString(),
                    unit: _sugarLeft <= 0 ? null : 'g',
                    progress: _calculateProgress(_totalSugar, sugarGoal),
                    progressColor: Colors.pink[300],
                    icon: Icons.icecream,
                    iconColor: Colors.pink[300],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Sodium',
                    subtitle: _sodiumLeft <= 0 ? null : 'left',
                    value: _sodiumLeft <= 0 ? 'Criteria Met' : _sodiumLeft.round().toString(),
                    unit: _sodiumLeft <= 0 ? null : 'mg',
                    progress: _calculateProgress(_totalSodium, sodiumGoal),
                    progressColor: Colors.amber[300],
                    icon: Icons.grain,
                    iconColor: Colors.amber[300],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Health Score and Weeks Remaining Row
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Health Score Card
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Health Score Breakdown'),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• Calories (4 pts): Within ±10% of goal'),
                              SizedBox(height: 8),
                              Text('• Protein (2 pts): > 90% of goal'),
                              SizedBox(height: 8),
                              Text('• Fiber (2 pts): > 90% of goal'),
                              SizedBox(height: 8),
                              Text('• Sugar & Sodium (2 pts): Both below limits'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Health score',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.info_outline, size: 14, color: Theme.of(context).disabledColor),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_calculateHealthScore()}/10',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _calculateHealthScore() / 10.0,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Weeks Remaining Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Weeks remaining',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _calculateWeeksRemaining(),
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
          ),
        );
      }),
    );
  }
}
