import 'package:dukoavote/src/features/onboarding/domain/entities/onboarding_data.dart';

/// Interface du repository pour les données d'onboarding
abstract class OnboardingRepository {
  /// Récupère les données d'onboarding stockées localement
  Future<OnboardingData?> getOnboardingData();
  
  /// Vérifie si l'onboarding est terminé
  Future<bool> isOnboardingCompleted();
  
  /// Sauvegarde les données d'onboarding en local
  Future<void> saveOnboardingData(OnboardingData data);
  
  /// Synchronise les données d'onboarding avec Supabase
  Future<void> syncOnboardingData(OnboardingData data, String userId);
  
  /// Supprime les données d'onboarding locales après sync
  Future<void> clearOnboardingData();
} 