import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static const defaultGeminiModel = 'gemini-3.5-flash';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env', isOptional: true);
  }

  static String get geminiApiKey {
    const buildTimeKey = String.fromEnvironment('GEMINI_API_KEY');
    if (buildTimeKey.trim().isNotEmpty) return buildTimeKey.trim();
    return _environmentValue('GEMINI_API_KEY');
  }

  static String get geminiModel {
    const buildTimeModel = String.fromEnvironment(
      'GEMINI_MODEL',
      defaultValue: defaultGeminiModel,
    );
    final configuredModel = _environmentValue('GEMINI_MODEL');
    return configuredModel.isEmpty ? buildTimeModel : configuredModel;
  }

  static String get geminiFallbackModel {
    const buildTimeModel = String.fromEnvironment(
      'GEMINI_FALLBACK_MODEL',
      defaultValue: defaultGeminiModel,
    );
    final configuredModel = _environmentValue('GEMINI_FALLBACK_MODEL');
    return configuredModel.isEmpty ? buildTimeModel : configuredModel;
  }

  static String _environmentValue(String key) {
    if (!dotenv.isInitialized) return '';
    return (dotenv.env[key] ?? '').trim();
  }
}
