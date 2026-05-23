import 'package:isar/isar.dart';

part 'macro_goal.g.dart';

@embedded
class MacroGoal {
  int? dayOfWeek; // 1-7, where 1 = Monday, 7 = Sunday
  int? tdeeGoal;
  double? proteinGoal;
  double? carbsGoal;
  double? fatGoal;
  double? fiberGoal;
  double? sugarGoal;
  double? sodiumGoal;
  double? proteinPercentage;
  double? carbsPercentage;
  double? fatPercentage;
}
