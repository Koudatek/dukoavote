import 'package:dukoavote/src/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:dukoavote/src/features/onboarding/domain/repository/onboarding_repository.dart';

/// Use case pour synchroniser les données d'onboarding avec Supabase
class SyncOnboardingData {
  final OnboardingRepository repository;

  SyncOnboardingData(this.repository);

  /// Exécute la synchronisation des données d'onboarding
  Future<void> call(String userId) async {
    // Récupérer les données d'onboarding stockées localement
    final onboardingData = await repository.getOnboardingData();
    
    if (onboardingData != null) {
      // Synchroniser avec Supabase
      await repository.syncOnboardingData(onboardingData, userId);
    }
  }
} 