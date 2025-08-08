import 'package:shared_preferences/shared_preferences.dart';

class OnboardingLocalStorage {
  static const String _birthDateKey = 'onboarding_birth_date';
  static const String _genderKey = 'onboarding_gender';
  static const String _countryKey = 'onboarding_country';
  static const String _usernameKey = 'onboarding_username';
  static const String _isCompletedKey = 'onboarding_completed';
  static const String _isSyncedKey = 'onboarding_synced';

  // Sauvegarder les données d'onboarding
  static Future<void> saveOnboardingData({
    required DateTime birthDate,
    required String gender,
    required String country,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_birthDateKey, birthDate.toIso8601String());
    await prefs.setString(_genderKey, gender);
    await prefs.setString(_countryKey, country);
    await prefs.setString(_usernameKey, username);
    await prefs.setBool(_isCompletedKey, true);
  }

  // Récupérer les données d'onboarding (même si synchronisées)
  static Future<Map<String, dynamic>?> getOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final birthDateString = prefs.getString(_birthDateKey);
    final gender = prefs.getString(_genderKey);
    final country = prefs.getString(_countryKey);
    final username = prefs.getString(_usernameKey);
    
    if (birthDateString == null || gender == null || country == null || username == null) {
      return null;
    }

    try {
      final birthDate = DateTime.parse(birthDateString);
      final now = DateTime.now();
      final age = now.year - birthDate.year - (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day) ? 1 : 0);
      
      return {
        'birthDate': birthDate,
        'gender': gender,
        'country': country,
        'username': username,
        'age': age,
      };
    } catch (e) {
      return null;
    }
  }

  // Récupérer les données d'onboarding non synchronisées
  static Future<Map<String, dynamic>?> getUnsyncedOnboardingData() async {
    final isSynced = await isOnboardingSynced();
    if (isSynced) {
      return null; // Données déjà synchronisées
    }
    return await getOnboardingData();
  }

  // Vérifier si l'onboarding est terminé
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isCompletedKey) ?? false;
  }

  // Marquer les données d'onboarding comme synchronisées
  static Future<void> markOnboardingAsSynced() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSyncedKey, true);
  }

  // Vérifier si les données d'onboarding ont été synchronisées
  static Future<bool> isOnboardingSynced() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isSyncedKey) ?? false;
  }

  // Supprimer les données d'onboarding (après sync avec Supabase)
  static Future<void> clearOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_birthDateKey);
    await prefs.remove(_genderKey);
    await prefs.remove(_countryKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_isCompletedKey);
    await prefs.remove(_isSyncedKey);
  }

  // Réinitialiser complètement l'onboarding (pour les tests)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Supprimer toutes les données d'onboarding
    await prefs.remove(_birthDateKey);
    await prefs.remove(_genderKey);
    await prefs.remove(_countryKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_isCompletedKey);
    await prefs.remove(_isSyncedKey);
    
    // S'assurer que le statut est bien à false
    await prefs.setBool(_isCompletedKey, false);
    await prefs.setBool(_isSyncedKey, false);
  }

  static Future<void> savePersonalData({
    required DateTime birthDate,
    required String gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_birthDateKey, birthDate.toIso8601String());
    await prefs.setString(_genderKey, gender);
  }

  static Future<void> saveLocationData({
    required String country,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_countryKey, country);
    
    final birthDateString = prefs.getString(_birthDateKey);
    final gender = prefs.getString(_genderKey);
    
    if (birthDateString != null && gender != null) {
      await prefs.setBool(_isCompletedKey, true);
    }
  }

  static Future<void> saveUsernameData({
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_usernameKey, username);
  }
} 