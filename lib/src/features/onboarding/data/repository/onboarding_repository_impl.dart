import 'package:dukoavote/src/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:dukoavote/src/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:dukoavote/src/features/onboarding/data/onboarding_local_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final SupabaseClient _supabaseClient;

  OnboardingRepositoryImpl(this._supabaseClient);

  @override
  Future<OnboardingData?> getOnboardingData() async {
    try {
      final data = await OnboardingLocalStorage.getOnboardingData();
      if (data != null) {
        return OnboardingData(
          birthDate: data['birthDate'] as DateTime,
          gender: data['gender'] as String,
          country: data['country'] as String,
          username: data['username'] as String,
        );
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des données d\'onboarding: $e');
      return null;
    }
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return await OnboardingLocalStorage.isOnboardingCompleted();
  }

  @override
  Future<void> saveOnboardingData(OnboardingData data) async {
    await OnboardingLocalStorage.saveOnboardingData(
      birthDate: data.birthDate,
      gender: data.gender,
      country: data.country,
      username: data.username,
    );
  }

  @override
  Future<void> syncOnboardingData(OnboardingData data, String userId) async {
    try {
      // Mettre à jour le profil utilisateur dans Supabase
      await _supabaseClient
          .from('users')
          .update(data.toMap())
          .eq('id', userId);

      // Supprimer les données locales après sync réussie
      await clearOnboardingData();
    } catch (e) {
      print('Erreur lors de la synchronisation des données d\'onboarding: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearOnboardingData() async {
    await OnboardingLocalStorage.clearOnboardingData();
  }
} 