import 'package:shared_preferences/shared_preferences.dart';

class OnboardingLocalStorage {
  static const String _keyGender = 'onboarding_gender';
  static const String _keyBirthDate = 'onboarding_birthdate';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  // --- Profil ---
  static Future<void> saveProfile({required String gender, required DateTime birthDate}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGender, gender);
    await prefs.setString(_keyBirthDate, birthDate.toIso8601String());
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final gender = prefs.getString(_keyGender);
    final birthDateStr = prefs.getString(_keyBirthDate);
    if (gender != null && birthDateStr != null) {
      return {
        'gender': gender,
        'birthDate': DateTime.tryParse(birthDateStr),
      };
    }
    return null;
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGender);
    await prefs.remove(_keyBirthDate);
  }

  // --- Onboarding completion ---
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
  }
} 