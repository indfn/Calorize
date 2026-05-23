import 'package:flutter_test/flutter_test.dart';
import 'package:calorize/utils/macro_calculator.dart';

void main() {
  group('MacroCalculator Tests', () {
    test('Calculate BMR for Male', () {
      // 10*80 + 6.25*180 - 5*25 + 5 = 800 + 1125 - 125 + 5 = 1805
      final bmr = MacroCalculator.calculateBMR(
        weightKg: 80,
        heightCm: 180,
        age: 25,
        gender: 'Male',
      );
      expect(bmr, 1805);
    });

    test('Calculate BMR for Female', () {
      // 10*60 + 6.25*165 - 5*30 - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
      final bmr = MacroCalculator.calculateBMR(
        weightKg: 60,
        heightCm: 165,
        age: 30,
        gender: 'Female',
      );
      expect(bmr, 1320);
    });

    test('Calculate TDEE (Moderate Activity)', () {
      final tdee = MacroCalculator.calculateTDEE(
        bmr: 1800,
        activityLevel: 'Moderate',
      );
      // 1800 * 1.55 = 2790
      expect(tdee, 2790);
    });

    test('Calculate Macros for High Protein', () {
      final macros = MacroCalculator.calculateMacros(
        targetCalories: 3050,
        weightKg: 80,
        goalType: 'gain',
        gender: 'Male',
        age: 25,
        dietPreference: 'High Protein',
      );

      // carbsRatio = 0.43 -> 3050 * 0.43 / 4 = 327.9
      // proteinRatio = 0.35 -> 3050 * 0.35 / 4 = 266.9
      // fatRatio = 0.22 -> 3050 * 0.22 / 9 = 74.6
      expect(macros['protein'], 266.9);
      expect(macros['fat'], 74.6);
      expect(macros['carbs'], 327.9);
      expect(macros['calories'], 3050.0);
    });

    test('Calculate Macros for Balanced', () {
      final macros = MacroCalculator.calculateMacros(
        targetCalories: 2000,
        weightKg: 80,
        goalType: 'lose',
        gender: 'Female',
        age: 30,
        dietPreference: 'Balanced',
      );

      // carbsRatio = 0.49 -> 2000 * 0.49 / 4 = 245.0
      // proteinRatio = 0.26 -> 2000 * 0.26 / 4 = 130.0
      // fatRatio = 0.25 -> 2000 * 0.25 / 9 = 55.6
      expect(macros['protein'], 130.0);
      expect(macros['fat'], 55.6);
      expect(macros['carbs'], 245.0);
      expect(macros['calories'], 2000.0);
    });
  });
}
