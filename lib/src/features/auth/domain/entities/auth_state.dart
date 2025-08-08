import 'package:supabase_flutter/supabase_flutter.dart';

/// État d'authentification de l'application
class AuthState {
  final User? _user;
  final String? error;

  const AuthState._({
    User? user,
    this.error,
  }) : _user = user;

  /// Indique si l'utilisateur est authentifié
  bool get isAuthenticated => _user != null;

  /// Retourne l'utilisateur courant
  User? get user => _user;

  /// État initial de l'authentification
  factory AuthState.initial() {
    return const AuthState._();
  }

  /// État authentifié avec un utilisateur
  factory AuthState.authenticated(User user) {
    return AuthState._(user: user);
  }

  /// État non authentifié
  factory AuthState.unauthenticated() {
    return const AuthState._();
  }

  /// État d'erreur
  factory AuthState.error(String message) {
    return AuthState._(error: message);
  }

  /// Crée une copie de l'état avec des modifications
  AuthState copyWith({
    User? user,
    String? error,
  }) {
    return AuthState._(
      user: user ?? _user,
      error: error ?? this.error,
    );
  }
}
