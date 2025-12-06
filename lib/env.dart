import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get kolosalApiKey => dotenv.env['KOLOSAL_API_KEY'] ?? '';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static bool validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not set in .env file');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not set in .env file');
    }
    if (geminiApiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not set in .env file');
    }
    if (kolosalApiKey.isEmpty) {
      throw Exception('KOLOSAL_API_KEY is not set in .env file');
    }
    if (apiBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env file');
    }
    return true;
  }
}
