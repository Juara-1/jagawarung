import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String _get(String key) {
    try {
      return dotenv.maybeGet(key, fallback: '') ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get supabaseUrl => _get('SUPABASE_URL');
  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY');
  static String get kolosalApiKey => _get('KOLOSAL_API_KEY');
  static String get apiBaseUrl => _get('API_BASE_URL');

  static bool validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not set in .env file');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not set in .env file');
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
