import 'package:isar/isar.dart';

part 'ai_provider.g.dart';

@embedded
class AIProvider {
  String? providerId; // 'openai', 'google', 'anthropic', 'custom'
  String? name;       // User-facing display name
  String? apiKey;
  String? baseUrl;
  String? modelId;
  String? apiType;    // 'openai', 'google', 'anthropic', 'custom'
  bool? isEnabled;
}
