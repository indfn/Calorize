import 'package:isar/isar.dart';

part 'ai_provider.g.dart';

@embedded
class AIProvider {
  String? providerId; // 'openai', 'google', 'anthropic', 'custom'
  String? apiKey;
  String? baseUrl;
  String? modelId;
  bool? isEnabled;
}
