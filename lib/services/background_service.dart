import 'dart:convert';
import 'dart:math';
import 'package:home_widget/home_widget.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/data/models/user_profile.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  Future<void> updateWidgetData() async {
    final db = DatabaseService();
    final profile = await db.getUserProfile();

    final now = DateTime.now();

    if (profile == null) {
      await _pushWidgetData(0, 0, 0, 0, 0, 0, 0);
      return;
    }

    final todayLogs = await db.getTodayFoodLogs();

    int currentCalories = 0;
    double currentProtein = 0;
    double currentCarbs = 0;
    double currentFat = 0;

    for (var log in todayLogs) {
      currentCalories += log.calories;
      currentProtein += log.macros.protein ?? 0;
      currentCarbs += log.macros.carbs ?? 0;
      currentFat += log.macros.fat ?? 0;
    }

    final baseGoal = profile.getTdeeGoalForDay(now.weekday);
    final caloriesLeft = (baseGoal - currentCalories).clamp(0, baseGoal);
    final progress = (currentCalories / max(baseGoal, 1) * 100).clamp(0, 100).toInt();

    double proteinGoal = profile.getProteinGoalForDay(now.weekday);
    double carbsGoal = profile.getCarbsGoalForDay(now.weekday);
    double fatGoal = profile.getFatGoalForDay(now.weekday);

    final proteinLeft = (proteinGoal - currentProtein).clamp(0, proteinGoal).round();
    final carbsLeft = (carbsGoal - currentCarbs).clamp(0, carbsGoal).round();
    final fatsLeft = (fatGoal - currentFat).clamp(0, fatGoal).round();

    await _pushWidgetData(
      caloriesLeft, currentCalories, baseGoal,
      progress, proteinLeft, carbsLeft, fatsLeft,
    );
  }

  Future<void> _pushWidgetData(
    int caloriesLeft, int caloriesConsumed, int caloriesGoal, int progress,
    int proteinLeft, int carbsLeft, int fatsLeft,
  ) async {
    final jsonString = jsonEncode({
      'caloriesLeft': caloriesLeft,
      'caloriesConsumed': caloriesConsumed,
      'caloriesGoal': caloriesGoal,
      'percentageText': '$progress%',
      'proteinLeft': proteinLeft,
      'carbsLeft': carbsLeft,
      'fatsLeft': fatsLeft,
      'progress': progress,
    });

    await HomeWidget.saveWidgetData('widget_data', jsonString);
    await HomeWidget.updateWidget(
      name: 'DashboardWidgetProvider',
      androidName: 'DashboardWidgetProvider',
    );
    await HomeWidget.updateWidget(
      name: 'ShortcutsWidgetProvider',
      androidName: 'ShortcutsWidgetProvider',
    );
  }
}
