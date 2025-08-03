import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Following the Either pattern from functional programming
abstract class Failure extends Equatable {
  const Failure([this.message = 'Une erreur inattendue s\'est produite']);
  
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur de connexion réseau']);
}

/// Server related failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur']);
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Erreur d\'authentification']);
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache']);
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Données invalides']);
}

/// Permission related failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission refusée']);
} 