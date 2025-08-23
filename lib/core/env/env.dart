import 'package:flutter_dotenv/flutter_dotenv.dart';


class Env {
  static late final String GeminiApiKey;
  static void initFromDotenv() {
    GeminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  }
}