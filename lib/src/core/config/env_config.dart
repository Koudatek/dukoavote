import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  static String get supabaseUrl {
    const key = 'SUPABASE_URL';
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('$key non définie dans le fichier .env');
    }
    return value;
  }

  static String get supabaseAnonKey {
    const key = 'SUPABASE_ANON_KEY';
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('$key non définie dans le fichier .env');
    }
    return value;
  }
}