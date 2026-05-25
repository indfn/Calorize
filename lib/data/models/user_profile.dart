import 'package:isar/isar.dart';
import 'ai_provider.dart';
import 'macro_goal.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  double? height;
  double? weight;
  DateTime? dob;
  String? gender;
  bool? isMetric; // True for Metric (kg/cm), False for Imperial (lbs/ft)
  
  // Goal Details
  String? goalType; // 'lose', 'maintain', 'gain'
  String? dietType; // 'Classic', 'Pescatarian', 'Vegetarian', 'Vegan'
  String? dietPreference; // 'Balanced', 'Low Carb', 'Low Fat', 'High Protein'
  double? targetWeight;
  String? activityLevel;
  double? weightLossRate; // kg per week
  int? tdeeGoal;

  // Macro/Micro Goals
  double? proteinGoal;
  double? carbsGoal;
  double? fatGoal;
  double? fiberGoal;
  double? sugarGoal;
  double? sodiumGoal;

  bool rolloverEnabled = false;
  int maxRollover = 200;
  int successTolerance = 200; 
  String? geminiApiKey;
  
  // Theme preference
  String themeMode = 'system'; // 'light', 'dark', 'system'
  
  // Macro split percentages
  double proteinPercentage = 30.0; 
  double carbsPercentage = 40.0;
  double fatPercentage = 30.0;

  // Notification Settings
  bool notificationsEnabled = false;
  
  // 🟢 NEW: Timezone Offset (Hours from UTC)
  // Default to 8 (Singapore/China) to match your current hardcode
  int utcOffset = 8; 

  int breakfastTime = 480; // 8:00 AM in minutes from midnight
  int lunchTime = 780;     // 1:00 PM
  int dinnerTime = 1140;   // 7:00 PM

  List<AIProvider>? aiProviders;
  String? aiRoutingMode; // null/'fill_up' = fill up first, 'round_robin' = round robin
  List<MacroGoal>? weeklyGoals;
}

extension UserProfileGoalsExtension on UserProfile {
  MacroGoal? getGoalForDay(int dayOfWeek) {
    if (weeklyGoals == null) return null;
    for (final goal in weeklyGoals!) {
      if (goal.dayOfWeek == dayOfWeek) return goal;
    }
    return null;
  }

  int getTdeeGoalForDay(int dayOfWeek) {
    final dayGoal = getGoalForDay(dayOfWeek);
    return dayGoal?.tdeeGoal ?? tdeeGoal ?? 2000;
  }

  double getProteinGoalForDay(int dayOfWeek) {
    final dayGoal = getGoalForDay(dayOfWeek);
    if (dayGoal?.proteinGoal != null) return dayGoal!.proteinGoal!;
    if (proteinGoal != null) return proteinGoal!;
    
    final baseGoal = getTdeeGoalForDay(dayOfWeek);
    final pct = (dayGoal?.proteinPercentage ?? proteinPercentage) / 100;
    return baseGoal * pct / 4;
  }

  double getCarbsGoalForDay(int dayOfWeek) {
    final dayGoal = getGoalForDay(dayOfWeek);
    if (dayGoal?.carbsGoal != null) return dayGoal!.carbsGoal!;
    if (carbsGoal != null) return carbsGoal!;
    
    final baseGoal = getTdeeGoalForDay(dayOfWeek);
    final pct = (dayGoal?.carbsPercentage ?? carbsPercentage) / 100;
    return baseGoal * pct / 4;
  }

  double getFatGoalForDay(int dayOfWeek) {
    final dayGoal = getGoalForDay(dayOfWeek);
    if (dayGoal?.fatGoal != null) return dayGoal!.fatGoal!;
    if (fatGoal != null) return fatGoal!;
    
    final baseGoal = getTdeeGoalForDay(dayOfWeek);
    final pct = (dayGoal?.fatPercentage ?? fatPercentage) / 100;
    return baseGoal * pct / 9;
  }

  double getFiberGoalForDay(int dayOfWeek) {
    final dayGoal = getGoalForDay(dayOfWeek);
    return dayGoal?.fiberGoal ?? fiberGoal ?? 30.0;
  }

  double getSugarGoalForDay(int dayOfWeek) {
    final dayGoal = getGoalForDay(dayOfWeek);
    return dayGoal?.sugarGoal ?? sugarGoal ?? 50.0;
  }

  double getSodiumGoalForDay(int dayOfWeek) {
    final dayGoal = getGoalForDay(dayOfWeek);
    return dayGoal?.sodiumGoal ?? sodiumGoal ?? 2300.0;
  }
}