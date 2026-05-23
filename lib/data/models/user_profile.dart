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
  List<MacroGoal>? weeklyGoals;
}