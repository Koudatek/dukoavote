import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static const String _supabaseUrlKey = 'SUPABASE_URL';
  static const String _supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';

  /// Charge les variables d'environnement depuis le fichier .env
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// Récupère l'URL Supabase depuis les variables d'environnement
  static String get supabaseUrl {
    final url = dotenv.env[_supabaseUrlKey];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL non définie dans le fichier .env');
    }
    return url;
  }

  /// Récupère la clé anonyme Supabase depuis les variables d'environnement
  static String get supabaseAnonKey {
    final key = dotenv.env[_supabaseAnonKeyKey];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY non définie dans le fichier .env');
    }
    return key;
  }

  /// Vérifie que toutes les variables d'environnement requises sont présentes
  static void validate() {
    supabaseUrl; // Lance une exception si manquante
    supabaseAnonKey; // Lance une exception si manquante
  }
} 