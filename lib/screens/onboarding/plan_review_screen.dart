import 'package:flutter/material.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/data/models/ai_provider.dart';
import 'package:calorize/screens/home_screen.dart';
import 'package:calorize/utils/macro_calculator.dart';
import 'package:fl_chart/fl_chart.dart';

class PlanReviewScreen extends StatelessWidget {
  final int calories;
  final Map<String, double> macros;
  final int weeksToGoal;
  final Map<String, dynamic> userProfileData;

  const PlanReviewScreen({
    super.key,
    required this.calories,
    required this.macros,
    required this.weeksToGoal,
    required this.userProfileData,
  });

  Future<void> _saveAndContinue(BuildContext context) async {
    debugPrint('Start Journey button pressed');
    final isar = DatabaseService().isar;

    try {
      debugPrint('Creating UserProfile object...');
      final userProfile = UserProfile()
        ..gender = userProfileData['gender']
        ..dob = userProfileData['dob']
        ..height = userProfileData['height']
        ..weight = userProfileData['weight']
        ..activityLevel = userProfileData['activityLevel']
        ..goalType = userProfileData['goalType']

        ..dietPreference = userProfileData['dietPreference']
        ..targetWeight = userProfileData['targetWeight']
        ..weightLossRate = userProfileData['weightLossRate']
        ..rolloverEnabled = userProfileData['rolloverEnabled']
        ..isMetric = userProfileData['isMetric']
        ..tdeeGoal = calories
        ..proteinGoal = macros['protein']
        ..fatGoal = macros['fat']
        ..carbsGoal = macros['carbs']
        ..fiberGoal = macros['fiber']
        ..sugarGoal = macros['sugar']
        ..sodiumGoal = macros['sodium']
        ..proteinPercentage = (() {
          final pref = userProfileData['dietPreference'] as String? ?? 'Balanced';
          final ratios = MacroCalculator.getRatiosForDiet(pref);
          return (ratios['protein'] ?? 0.27) * 100;
        })()
        ..carbsPercentage = (() {
          final pref = userProfileData['dietPreference'] as String? ?? 'Balanced';
          final ratios = MacroCalculator.getRatiosForDiet(pref);
          return (ratios['carbs'] ?? 0.49) * 100;
        })()
        ..fatPercentage = (() {
          final pref = userProfileData['dietPreference'] as String? ?? 'Balanced';
          final ratios = MacroCalculator.getRatiosForDiet(pref);
          return (ratios['fat'] ?? 0.24) * 100;
        })();

      final aiProvider = userProfileData['aiProvider'] as AIProvider?;
      if (aiProvider != null) {
        userProfile.aiProviders = [aiProvider];
      }
      
      debugPrint('UserProfile created. Writing to Isar...');
      await isar.writeTxn(() async {
        await isar.userProfiles.put(userProfile);
      });
      debugPrint('Profile saved to Isar.');

      if (context.mounted) {
        debugPrint('Navigating to HomeScreen...');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        debugPrint('Context not mounted, cannot navigate.');
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _saveAndContinue: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            _buildCalorieRing(context),
            const SizedBox(height: 32),
            _buildMacroLegend(),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Micro-nutrients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _buildMicroList(context),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _saveAndContinue(context),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Start Journey', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 48), // Bottom padding for Android home indicator
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieRing(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 80,
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: macros['protein'],
                  title: '',
                  radius: 20,
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: macros['carbs'],
                  title: '',
                  radius: 20,
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: macros['fat'],
                  title: '',
                  radius: 20,
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$calories',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text('kcal/day', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                if (weeksToGoal > 0)
                  Text('Goal in ~$weeksToGoal wks', style: const TextStyle(fontSize: 12, color: Colors.green))
                else
                  const Text('Maintenance', style: TextStyle(fontSize: 12, color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Protein', '${macros['protein']}g', Colors.blue),
        _buildLegendItem('Carbs', '${macros['carbs']}g', Colors.orange),
        _buildLegendItem('Fat', '${macros['fat']}g', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildMicroList(BuildContext context) {
    return Column(
      children: [
        _buildMicroItem(context, 'Fiber', '${macros['fiber']}g', Colors.green),
        _buildMicroItem(context, 'Sugar', '<${macros['sugar']}g', Colors.purple),
        _buildMicroItem(context, 'Sodium', '<${macros['sodium']}mg', Colors.teal),
      ],
    );
  }

  Widget _buildMicroItem(BuildContext context, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.circle, size: 8, color: color),
          ),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
