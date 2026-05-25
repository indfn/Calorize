import 'dart:convert';
import 'dart:math';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/data/models/macro_goal.dart';
import 'package:calorize/data/models/food_log.dart';
import 'package:calorize/data/models/daily_stat.dart';
import 'package:calorize/data/models/ai_provider.dart';
import 'package:calorize/services/background_service.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  late Isar isar;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [UserProfileSchema, FoodLogSchema, DailyStatSchema],
      directory: dir.path,
    );

    // Perform cleanup on startup
    await cleanOldLogs();
  }

  Future<void> cleanOldLogs() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    
    // Delete FoodLogs older than 7 days
    await isar.writeTxn(() async {
      await isar.foodLogs.filter()
          .timestampLessThan(cutoff)
          .deleteAll();
    });
  }

  Future<List<FoodLog>> getRecentFoodLogs({int limit = 3}) async {
    return await isar.foodLogs.where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }

  Future<UserProfile?> getUserProfile() async {
    return await isar.userProfiles.where().findFirst();
  }

  Future<List<FoodLog>> getTodayFoodLogs() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await isar.foodLogs.filter()
        .timestampBetween(startOfDay, endOfDay)
        .findAll();
  }

  Stream<List<FoodLog>> watchTodayFoodLogs() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return isar.foodLogs.filter()
        .timestampBetween(startOfDay, endOfDay)
        .watch(fireImmediately: true);
  }

  Future<void> addFoodLog(FoodLog log) async {
    await isar.writeTxn(() async {
      // 1. Save FoodLog
      await isar.foodLogs.put(log);

      // 2. Update DailyStat
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      
      final stat = await isar.dailyStats.filter()
          .dateEqualTo(date)
          .findFirst();

      if (stat != null) {
        stat.totalCalories += log.calories;
        stat.totalProtein += log.macros.protein ?? 0;
        stat.totalCarbs += log.macros.carbs ?? 0;
        stat.totalFat += log.macros.fat ?? 0;
        await isar.dailyStats.put(stat);
      } else {
        final newStat = DailyStat()
          ..date = date
          ..totalCalories = log.calories
          ..totalProtein = log.macros.protein ?? 0
          ..totalCarbs = log.macros.carbs ?? 0
          ..totalFat = log.macros.fat ?? 0;
        await isar.dailyStats.put(newStat);
      }
    });
    
    // Evaluate day success after adding food
    await evaluateDaySuccess(log.timestamp);
    
    // Update home screen widgets
    try {
      await BackgroundService().updateWidgetData();
    } catch (e) {
      debugPrint('Failed to update widgets: $e');
    }
  }



  Future<void> logWeight(double weight) async {
    await isar.writeTxn(() async {
      // 1. Update UserProfile
      final profile = await isar.userProfiles.where().findFirst();
      if (profile != null) {
        profile.weight = weight;
        await isar.userProfiles.put(profile);
      }

      // 2. Update DailyStat
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      
      final stat = await isar.dailyStats.filter()
          .dateEqualTo(date)
          .findFirst();

      if (stat != null) {
        stat.weightEntry = weight;
        await isar.dailyStats.put(stat);
      } else {
        final newStat = DailyStat()
          ..date = date
          ..totalCalories = 0
          ..weightEntry = weight;
        await isar.dailyStats.put(newStat);
      }
    });
  }

  // Analytics & Stats

  Future<DailyStat> _getOrCreateDailyStat(DateTime date) async {
    var stat = await isar.dailyStats.filter().dateEqualTo(date).findFirst();
    if (stat == null) {
      stat = DailyStat()..date = date..totalCalories = 0;
      await isar.writeTxn(() => isar.dailyStats.put(stat!));
    }
    return stat;
  }

  Future<void> evaluateDaySuccess(DateTime date) async {
    final profile = await getUserProfile();
    if (profile == null) return;
    
    final dateOnly = DateTime(date.year, date.month, date.day);
    final stat = await _getOrCreateDailyStat(dateOnly);
    
    // Get previous day's rollover
    final yesterday = dateOnly.subtract(const Duration(days: 1));
    final yesterdayStat = await isar.dailyStats
        .filter()
        .dateEqualTo(yesterday)
        .findFirst();
    
    final rolloverFromYesterday = (profile.rolloverEnabled && yesterdayStat != null)
        ? yesterdayStat.rolloverToNextDay
        : 0.0;
    
    stat.rolloverFromPreviousDay = rolloverFromYesterday;
    
    // Calculate success based on DAY goal
    final baseGoal = profile.getTdeeGoalForDay(dateOnly.weekday);
    final tolerance = profile.successTolerance;
    final actualCalories = stat.totalCalories;
    
    // Success = within tolerance of DAY goal
    stat.goalMetWithinRange = (actualCalories > 0) &&
        (actualCalories >= baseGoal - tolerance) &&
        (actualCalories <= baseGoal + tolerance);
    
    // Calculate rollover for tomorrow (guidance)
    if (profile.rolloverEnabled && actualCalories > 0) {
      final rolloverLimit = profile.maxRollover;
      // INVERTED: baseGoal - actual (compensation logic)
      final deficit = baseGoal - actualCalories;
      stat.rolloverToNextDay = deficit.clamp(-rolloverLimit.toDouble(), rolloverLimit.toDouble()).toDouble();
    } else {
      stat.rolloverToNextDay = 0;
    }
    
    await isar.writeTxn(() => isar.dailyStats.put(stat));
  }

  Future<int> getCurrentStreak() async {
    final profile = await getUserProfile();
    if (profile == null) return 0;
    
    final stats = await isar.dailyStats.where().sortByDateDesc().findAll();
    if (stats.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    final tolerance = profile.successTolerance;

    final datesMetGoal = stats
        .where((stat) {
          final actualCalories = stat.totalCalories;
          final baseGoal = profile.getTdeeGoalForDay(stat.date.weekday);
          return (actualCalories > 0) &&
              (actualCalories >= baseGoal - tolerance) &&
              (actualCalories <= baseGoal + tolerance);
        })
        .map((stat) => DateTime(stat.date.year, stat.date.month, stat.date.day))
        .toSet()
        .toList()
        ..sort((a, b) => b.compareTo(a));

    if (datesMetGoal.isEmpty) return 0;

    if (datesMetGoal.first != todayDate && datesMetGoal.first != yesterdayDate) {
      return 0;
    }

    int streak = 0;
    DateTime currentCheck = datesMetGoal.first;
    
    for (var date in datesMetGoal) {
      if (date == currentCheck) {
        streak++;
        currentCheck = currentCheck.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  Future<Map<DateTime, bool>> getWeeklySuccessStatus() async {
    final now = DateTime.now();
    final profile = await getUserProfile();
    
    // Get start of current week (Monday)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final stats = await isar.dailyStats
        .filter()
        .dateBetween(startOfWeek, endOfWeek)
        .findAll();

    final Map<DateTime, bool> status = {};
    
    // Default values if profile is missing
    final tolerance = profile?.successTolerance ?? 50;

    for (var stat in stats) {
      final date = DateTime(stat.date.year, stat.date.month, stat.date.day);
      
      // Dynamic calculation to ensure settings changes are reflected immediately
      final actualCalories = stat.totalCalories;
      final baseGoal = profile?.getTdeeGoalForDay(date.weekday) ?? 2000;
      final isSuccess = (actualCalories > 0) &&
          (actualCalories >= baseGoal - tolerance) &&
          (actualCalories <= baseGoal + tolerance);
          
      status[date] = isSuccess;
    }
    return status;
  }

  Future<List<DailyStat>> getWeeklyStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final stats = <DailyStat>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      
      final stat = await isar.dailyStats.filter()
          .dateEqualTo(date)
          .findFirst();
          
      if (stat != null) {
        stats.add(stat);
      } else {
        stats.add(DailyStat()
          ..date = date
          ..totalCalories = 0
          ..weightEntry = 0
          ..bmi = 0
        );
      }
    }
    return stats;
  }

  Future<List<DailyStat>> getWeightHistory(int days) async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));
    
    return isar.dailyStats.filter()
        .dateGreaterThan(cutoff)
        .sortByDate()
        .findAll();
  }

  Future<List<DailyStat>> getCalorieHistory(int days) async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));
    
    return isar.dailyStats.filter()
        .dateGreaterThan(cutoff)
        .sortByDate()
        .findAll();
  }



  Stream<List<FoodLog>> watchRecentFoodLogs() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return isar.foodLogs.filter()
        .timestampGreaterThan(cutoff)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  // Helper function for BMI
  // Assumes weight in kg and height in cm
  double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    final heightM = height / 100;
    return weight / (heightM * heightM);
  }

  Future<void> saveWeeklyGoal(int dayOfWeek, MacroGoal goal) async {
    final profile = await getUserProfile();
    if (profile == null) return;

    goal.dayOfWeek = dayOfWeek;
    profile.weeklyGoals ??= [];
    final index = profile.weeklyGoals!.indexWhere((g) => g.dayOfWeek == dayOfWeek);
    if (index >= 0) {
      profile.weeklyGoals![index] = goal;
    } else {
      profile.weeklyGoals!.add(goal);
    }

    await isar.writeTxn(() => isar.userProfiles.put(profile));
  }

  Future<void> applyConstantGoals(MacroGoal baseGoal) async {
    final profile = await getUserProfile();
    if (profile == null) return;

    profile.weeklyGoals = [];
    for (int day = 1; day <= 7; day++) {
      final goal = MacroGoal()
        ..dayOfWeek = day
        ..tdeeGoal = baseGoal.tdeeGoal
        ..proteinGoal = baseGoal.proteinGoal
        ..carbsGoal = baseGoal.carbsGoal
        ..fatGoal = baseGoal.fatGoal
        ..fiberGoal = baseGoal.fiberGoal
        ..sugarGoal = baseGoal.sugarGoal
        ..sodiumGoal = baseGoal.sodiumGoal
        ..proteinPercentage = baseGoal.proteinPercentage
        ..carbsPercentage = baseGoal.carbsPercentage
        ..fatPercentage = baseGoal.fatPercentage;
      profile.weeklyGoals!.add(goal);
    }

    await isar.writeTxn(() => isar.userProfiles.put(profile));
  }

  Future<void> clearWeeklyGoals() async {
    final profile = await getUserProfile();
    if (profile == null) return;

    profile.weeklyGoals = [];
    await isar.writeTxn(() => isar.userProfiles.put(profile));
  }

  Future<List<FoodLog>> getAllFoodLogs() async {
    return await isar.foodLogs.where().sortByTimestampDesc().findAll();
  }

  Future<String> exportFoodLogsAsJson() async {
    final logs = await getAllFoodLogs();
    final profile = await getUserProfile();
    final stats = await isar.dailyStats.where().sortByDateDesc().findAll();

    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'profile': profile != null ? {
        'goalType': profile.goalType,
        'tdeeGoal': profile.tdeeGoal,
        'proteinGoal': profile.proteinGoal,
        'carbsGoal': profile.carbsGoal,
        'fatGoal': profile.fatGoal,
        'height': profile.height,
        'weight': profile.weight,
        'activityLevel': profile.activityLevel,
      } : null,
      'foodLogs': logs.map((log) => {
        'foodName': log.foodName,
        'calories': log.calories,
        'protein': log.macros.protein,
        'carbs': log.macros.carbs,
        'fat': log.macros.fat,
        'timestamp': log.timestamp.toIso8601String(),
      }).toList(),
      'dailyStats': stats.map((stat) => {
        'date': stat.date.toIso8601String(),
        'totalCalories': stat.totalCalories,
        'totalProtein': stat.totalProtein,
        'totalCarbs': stat.totalCarbs,
        'totalFat': stat.totalFat,
        'goalMetWithinRange': stat.goalMetWithinRange,
      }).toList(),
    };

    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(exportData);
  }

  Future<void> generateSampleData() async {
    final now = DateTime.now();
    final random = Random();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day - 7);

    await isar.writeTxn(() async {
      await isar.foodLogs.filter()
          .timestampGreaterThan(sevenDaysAgo)
          .deleteAll();
      await isar.dailyStats.filter()
          .dateGreaterThan(sevenDaysAgo)
          .deleteAll();
    });

    final sampleFoods = [
      {'name': 'Oatmeal with Berries', 'cal': 350, 'p': 12, 'c': 58, 'f': 8},
      {'name': 'Grilled Chicken Salad', 'cal': 450, 'p': 35, 'c': 15, 'f': 22},
      {'name': 'Salmon with Rice', 'cal': 550, 'p': 40, 'c': 45, 'f': 18},
      {'name': 'Greek Yogurt Parfait', 'cal': 280, 'p': 15, 'c': 35, 'f': 8},
      {'name': 'Turkey Sandwich', 'cal': 400, 'p': 28, 'c': 35, 'f': 14},
      {'name': 'Protein Smoothie', 'cal': 320, 'p': 25, 'c': 40, 'f': 5},
      {'name': 'Beef Stir Fry', 'cal': 500, 'p': 35, 'c': 30, 'f': 20},
      {'name': 'Mixed Nuts', 'cal': 180, 'p': 6, 'c': 8, 'f': 16},
    ];

    UserProfile profile;
    final existingProfile = await getUserProfile();
    if (existingProfile != null) {
      profile = existingProfile;
    } else {
      profile = UserProfile()
        ..tdeeGoal = 2000
        ..proteinGoal = 150
        ..carbsGoal = 250
        ..fatGoal = 65;
      await isar.writeTxn(() => isar.userProfiles.put(profile));
    }

    await isar.writeTxn(() async {
      for (int day = 6; day >= 0; day--) {
        final date = DateTime(now.year, now.month, now.day - day);
        int totalCal = 0;
        double totalP = 0, totalC = 0, totalF = 0;

        final meals = random.nextInt(3) + 3;
        for (int m = 0; m < meals; m++) {
          final food = sampleFoods[random.nextInt(sampleFoods.length)];
          final timestamp = DateTime(date.year, date.month, date.day,
              7 + m * 4 + random.nextInt(2), random.nextInt(60));

          final macros = Macros()
            ..protein = (food['p'] as int).toDouble()
            ..carbs = (food['c'] as int).toDouble()
            ..fat = (food['f'] as int).toDouble();

          final log = FoodLog()
            ..foodName = food['name'] as String
            ..calories = food['cal'] as int
            ..macros = macros
            ..timestamp = timestamp;

          await isar.foodLogs.put(log);

          totalCal += food['cal'] as int;
          totalP += (food['p'] as int).toDouble();
          totalC += (food['c'] as int).toDouble();
          totalF += (food['f'] as int).toDouble();
        }

        final stat = DailyStat()
          ..date = date
          ..totalCalories = totalCal
          ..totalProtein = totalP
          ..totalCarbs = totalC
          ..totalFat = totalF
          ..goalMetWithinRange = (totalCal - profile.getTdeeGoalForDay(date.weekday)).abs() < 200;

        await isar.dailyStats.put(stat);
      }
    });
  }

  Future<void> saveAiProviders(List<AIProvider> providers) async {
    final profile = await getUserProfile();
    if (profile != null) {
      await isar.writeTxn(() async {
        profile.aiProviders = providers;
        await isar.userProfiles.put(profile);
      });
    }
  }

  Future<void> resetAllData() async {
    await isar.writeTxn(() async {
      await isar.userProfiles.clear();
      await isar.foodLogs.clear();
      await isar.dailyStats.clear();
    });
    await BackgroundService().updateWidgetData();
  }
}
