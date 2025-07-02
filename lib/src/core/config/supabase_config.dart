import 'package:supabase_flutter/supabase_flutter.dart';
import 'env_config.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    // Charger les variables d'environnement
    await EnvConfig.load();
    
    // Valider que toutes les variables sont présentes
    EnvConfig.validate();
    
    // Initialiser Supabase avec les variables d'environnement
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  
  static User? get currentUser => client.auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;
} 