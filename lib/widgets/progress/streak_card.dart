import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/daily_stat.dart';
import 'package:calorize/data/models/user_profile.dart';

class StreakCard extends StatelessWidget {
  final int streakCount;
  final List<DailyStat> weeklyStats;
  final UserProfile? userProfile;

  const StreakCard({
    super.key,
    required this.streakCount,
    required this.weeklyStats,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 180, // Removed fixed height
      constraints: const BoxConstraints(minHeight: 180),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fire Icon
          Icon(
            Icons.local_fire_department_rounded,
            size: 40,
            color: streakCount > 0 ? Colors.orange : Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 4),
          Text(
            '$streakCount',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: streakCount > 0 ? Colors.orange : Theme.of(context).disabledColor,
            ),
          ),
          Text(
            'Day streak',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: streakCount > 0 ? Colors.orange : Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 16), // Replaced Spacer with SizedBox
          // Dots Row
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildDots(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDots(BuildContext context) {
    List<Widget> dots = [];
    for (int i = 0; i < 7; i++) {
      // weeklyStats[0] is 6 days ago. weeklyStats[6] is today.
      final stat = weeklyStats.length > i ? weeklyStats[i] : null;
      final date = stat?.date ?? DateTime.now().subtract(Duration(days: 6 - i));
      final dayLetter = _getDayLetter(date.weekday);
      
      final baseGoal = userProfile?.getTdeeGoalForDay(date.weekday) ?? 2000;
      final tolerance = userProfile?.successTolerance ?? 50;
      
      final isGoalMet = stat != null && 
          stat.totalCalories > 0 &&
          stat.totalCalories >= (baseGoal - tolerance) &&
          stat.totalCalories <= (baseGoal + tolerance);

      dots.add(
        Column(
          children: [
            Text(
              dayLetter,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 18, // Smaller dots to fit
              height: 18,
              decoration: BoxDecoration(
                color: isGoalMet ? const Color(0xFF4ADE80) : Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: isGoalMet 
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      );
    }
    return dots;
  }

  String _getDayLetter(int weekday) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return letters[weekday - 1];
  }
}
