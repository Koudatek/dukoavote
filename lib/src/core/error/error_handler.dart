import 'package:supabase_flutter/supabase_flutter.dart';
import 'failures.dart';

/// Centralized error handler that converts exceptions to typed failures
/// Following the principle of error handling at the boundaries
class ErrorHandler {
  const ErrorHandler._();

  /// Converts any exception to a typed Failure
  static Failure handle(dynamic error) {
    // Handle Supabase specific errors
    if (error is AuthException) {
      return _handleAuthException(error);
    }
    
    if (error is PostgrestException) {
      return _handlePostgrestException(error);
    }
    
    if (error is StorageException) {
      return _handleStorageException(error);
    }
    
    /*if (error is RealtimeException) {
      return _handleRealtimeException(error);
    }*/
    
    // Handle network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return const NetworkFailure();
    }
    
    // Handle timeout errors
    if (error.toString().contains('TimeoutException')) {
      return const NetworkFailure('Délai d\'attente dépassé');
    }
    
    // Default case
    return ServerFailure(error.toString());
  }

  static Failure _handleAuthException(AuthException error) {
    switch (error.statusCode) {
      case '400':
        return const AuthFailure('Données d\'authentification invalides');
      case '401':
        return const AuthFailure('Non autorisé');
      case '403':
        return const AuthFailure('Accès refusé');
      case '404':
        return const AuthFailure('Utilisateur non trouvé');
      case '422':
        return const ValidationFailure('Données de validation invalides');
      case '429':
        return const AuthFailure('Trop de tentatives, réessayez plus tard');
      default:
        return AuthFailure('Erreur d\'authentification: ${error.message}');
    }
  }

  static Failure _handlePostgrestException(PostgrestException error) {
    switch (error.code) {
      case 'PGRST116':
        return const ValidationFailure('Données invalides');
      case 'PGRST301':
        return const AuthFailure('Non autorisé');
      case 'PGRST302':
        return const PermissionFailure('Permission refusée');
      default:
        return ServerFailure('Erreur base de données: ${error.message}');
    }
  }

  static Failure _handleStorageException(StorageException error) {
    switch (error.statusCode) {
      case '400':
        return const ValidationFailure('Fichier invalide');
      case '401':
        return const AuthFailure('Non autorisé');
      case '403':
        return const PermissionFailure('Permission refusée');
      case '404':
        return const ServerFailure('Fichier non trouvé');
      default:
        return ServerFailure('Erreur stockage: ${error.message}');
    }
  }

  /*static Failure _handleRealtimeException(RealtimeException error) {
    return ServerFailure('Erreur temps réel: ${error.message}');
  }*/
} 