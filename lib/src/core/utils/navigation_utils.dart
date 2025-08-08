import 'package:go_router/go_router.dart';

import '../../src.dart';

/// Utilitaires pour la navigation avec gestion d'erreurs
class NavigationUtils {
  /// Navigue vers la page de résultats avec gestion d'erreurs
  static void navigateToResults(
    GoRouter context, {
    String? pollId,
    String? userId,
    Poll? poll,
    String? errorMessage,
  }) {
    final queryParams = <String, String>{};
    
    if (pollId != null && pollId.isNotEmpty) {
      queryParams['pollId'] = pollId;
    }
    
    if (userId != null && userId.isNotEmpty) {
      queryParams['userId'] = userId;
    }
    
    if (errorMessage != null && errorMessage.isNotEmpty) {
      queryParams['error'] = errorMessage;
    }
    
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    final url = queryString.isNotEmpty 
        ? '${RouteNames.results}?$queryString'
        : RouteNames.results;
    
    context.go(url, extra: poll);
  }
  
  /// Navigue vers la page d'erreur de résultats
  static void navigateToResultsError(
    GoRouter context, {
    String? pollId,
    String? errorMessage,
  }) {
    final queryParams = <String, String>{};
    
    if (pollId != null && pollId.isNotEmpty) {
      queryParams['pollId'] = pollId;
    }
    
    if (errorMessage != null && errorMessage.isNotEmpty) {
      queryParams['error'] = errorMessage;
    }
    
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    final url = queryString.isNotEmpty 
        ? '${RouteNames.results}?$queryString'
        : RouteNames.results;
    
    context.go(url);
  }
  
  /// Valide les paramètres de navigation vers les résultats
  static bool isValidResultsNavigation({
    String? pollId,
    Poll? poll,
  }) {
    // Si on a un objet Poll, c'est valide
    if (poll != null) return true;
    
    // Si on a un pollId non vide, c'est valide
    if (pollId != null && pollId.isNotEmpty) return true;
    
    return false;
  }
  
  /// Génère un message d'erreur approprié
  static String getErrorMessage({
    String? pollId,
    Poll? poll,
    String? customError,
  }) {
    if (customError != null && customError.isNotEmpty) {
      return customError;
    }
    
    if (pollId == null || pollId.isEmpty) {
      return 'Aucun sondage sélectionné';
    }
    
    if (poll == null) {
      return 'Sondage introuvable';
    }
    
    return 'Erreur inconnue';
  }
} 