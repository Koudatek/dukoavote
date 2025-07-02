import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPreferences {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Sauvegarde que l'onboarding a été complété
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  /// Vérifie si l'onboarding a été complété
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Reset l'onboarding (pour les tests ou reset utilisateur)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
  }
} 