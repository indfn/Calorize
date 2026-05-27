import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:calorize/data/models/food_log.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/services/ai_routing_service.dart';

class FoodSourcingService {

  Future<FoodLog?> getProductByBarcode(String code) async {
    try {
      final configuration = ProductQueryConfiguration(
        code,
        language: OpenFoodFactsLanguage.ENGLISH,
        fields: [
          ProductField.NAME,
          ProductField.BRANDS,
          ProductField.NUTRIMENTS,
          ProductField.SERVING_SIZE,
          ProductField.SERVING_QUANTITY,
        ],
        version: ProductQueryVersion.v3,
      );

      final result = await OpenFoodAPIClient.getProductV3(configuration);

      if (result.product != null) {
        final product = result.product!;
        final nutriments = product.nutriments;
        
        double servingFactor = 1.0;

        if (product.servingQuantity != null && product.servingQuantity! > 0) {
          servingFactor = product.servingQuantity! / 100.0;
        }

        return FoodLog()
          ..foodName = product.productName ?? 'Unknown Food'
          ..brandName = product.brands
          ..calories = ((nutriments?.getValue(Nutrient.energyKCal, PerSize.serving) ?? 
                         (nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0) * servingFactor)).round()
          ..macros = Macros()
          ..macros.protein = (nutriments?.getValue(Nutrient.proteins, PerSize.serving) ?? 
                              (nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0) * servingFactor)
          ..macros.carbs = (nutriments?.getValue(Nutrient.carbohydrates, PerSize.serving) ?? 
                            (nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ?? 0) * servingFactor)
          ..macros.fat = (nutriments?.getValue(Nutrient.fat, PerSize.serving) ?? 
                          (nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0) * servingFactor)
          ..macros.fiber = (nutriments?.getValue(Nutrient.fiber, PerSize.serving) ?? 
                            (nutriments?.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0) * servingFactor)
          ..macros.sugar = (nutriments?.getValue(Nutrient.sugars, PerSize.serving) ?? 
                            (nutriments?.getValue(Nutrient.sugars, PerSize.oneHundredGrams) ?? 0) * servingFactor)
          ..macros.sodium = (nutriments?.getValue(Nutrient.sodium, PerSize.serving) ?? 
                             (nutriments?.getValue(Nutrient.sodium, PerSize.oneHundredGrams) ?? 0) * servingFactor) * 1000;
      }
    } catch (e) {
      print('Error fetching product: $e');
    }
    return null;
  }

  Future<FoodLog?> analyzeImage(File image, String userContext) async {
    final profile = await DatabaseService().getUserProfile();
    final providers = profile?.aiProviders ?? [];

    final enabled = providers.where((p) => p.isEnabled == true).toList();
    if (enabled.isEmpty) {
      throw Exception('No AI providers configured. Add one in Settings.');
    }

    await AiRoutingService().loadSettings();

    final imageBytes = await image.readAsBytes();
    List<String> errors = [];

    for (int attempt = 0; attempt < enabled.length; attempt++) {
      final provider = AiRoutingService().getNextProvider(providers, attempt: attempt);
      if (provider == null) continue;

      try {
        final mimeType = _detectMimeType(imageBytes);
        final responseText = await AiRoutingService().sendImageRequest(
          provider,
          _buildPrompt(userContext),
          imageBytes,
          mimeType: mimeType,
        );

        AiRoutingService().advanceRoundRobin(attempt + 1, enabled.length);

        final jsonStr = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
        final decoded = jsonDecode(jsonStr);

        if (decoded is! Map) throw FormatException('AI response is not a JSON object');
        final data = decoded as Map<String, dynamic>;

        final macros = data['macros'];
        if (macros is! Map) throw FormatException('AI response missing macros');

        final micros = data['micros'];

        return FoodLog()
          ..foodName = (data['name'] as String?) ?? 'Unknown Food'
          ..calories = (data['calories'] as num?)?.toInt() ?? 0
          ..timestamp = DateTime.now()
          ..macros = Macros()
          ..macros.protein = (macros['p'] as num?)?.toDouble() ?? 0
          ..macros.carbs = (macros['c'] as num?)?.toDouble() ?? 0
          ..macros.fat = (macros['f'] as num?)?.toDouble() ?? 0
          ..macros.fiber = (micros is Map ? (micros['fiber'] as num?)?.toDouble() : 0) ?? 0
          ..macros.sugar = (micros is Map ? (micros['sugar'] as num?)?.toDouble() : 0) ?? 0
          ..macros.sodium = (micros is Map ? (micros['sodium'] as num?)?.toDouble() : 0) ?? 0;
      } catch (e) {
        errors.add('${provider.name ?? provider.providerId}: $e');
        debugPrint('⚠️ AI provider ${provider.name} failed: $e');
        continue;
      }
    }

    throw Exception('All AI providers failed:\n${errors.join('\n')}');
  }

  String _detectMimeType(Uint8List bytes) {
    if (bytes.length >= 8) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
      if (bytes[0] == 0x89 && bytes[1] == 0x50) return 'image/png';
      if (bytes[0] == 0x47 && bytes[1] == 0x49) return 'image/gif';
      if (bytes[0] == 0x52 && bytes[1] == 0x49) return 'image/webp';
    }
    return 'image/jpeg';
  }

  String _buildPrompt(String userContext) {
    return '''
Analyze this food image. Context: '$userContext'.
Use Google Search to verify nutritional information.
1. Identify the food item.
2. Estimate the portion size based on visual cues (plate size, utensils). If unsure, assume a STANDARD SINGLE SERVING size (e.g. 1 cup/plate).
3. Calculate nutrition based on this estimated portion. BE REALISTIC. Do not overestimate.
4. Return a SINGLE JSON object with this exact structure (no markdown, no backticks):
{
  "name": "Food Name",
  "calories": 0,
  "macros": {
    "p": 0,
    "c": 0,
    "f": 0
  },
  "micros": {
    "fiber": 0,
    "sugar": 0,
    "sodium": 0
  }
}
Ensure calories are an integer. Macros/micros can be floats. Sodium in mg, others in g.
''';
  }
}
