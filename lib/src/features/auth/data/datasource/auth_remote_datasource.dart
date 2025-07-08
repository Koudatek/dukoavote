import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/utils/app_logger.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel?> signInWithEmail(String email, String password);
  Future<UserModel?> signUpWithEmail(String email, String password);
  Future<UserModel?> signInAnonymously(String gender, String birthDate, String age);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient client;

  AuthRemoteDatasourceImpl(this.client);

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    AppLogger.w('Tentative de connexion avec email');
    try {
      final response = await client.auth.signInWithPassword(email: email, password: password);
      final user = response.user;
      if (user == null) throw AuthException("Identifiants invalides.");
      AppLogger.w('Connexion réussie : ${user.id}');
      return UserModel(id: user.id, email: user.email);
    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException : $e');
      rethrow;
    } catch (e) {
      AppLogger.e('Erreur inattendue : $e');
      throw AuthException("Erreur lors de la connexion : $e");
    }
  }

  @override
  Future<UserModel?> signUpWithEmail(String email, String password) async {
    AppLogger.w('Tentative d\'inscription avec email');
    try {
      final response = await client.auth.signUp(email: email, password: password);
      final user = response.user;
      if (user == null) throw AuthException("Impossible de créer le compte.");
      AppLogger.w('Inscription réussie : ${user.id}');
      return UserModel(id: user.id, email: user.email);
    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException : $e');
      rethrow;
    } catch (e) {
      AppLogger.e('Erreur inattendue : $e');
      throw AuthException("Erreur lors de l'inscription : $e");
    }
  }

  @override
  Future<UserModel?> signInAnonymously(String gender, String birthDate, String age) async {
    AppLogger.w('Connexion anonyme');
    try {
      final response = await client.auth.signInAnonymously(
        data: {
          'gender': gender,
          'birth_date': birthDate.split('T').first,
          'age': age.toString(),
        },
      );
      final user = response.user;
      if (user == null) throw AuthException("Impossible de créer un utilisateur anonyme.");
      AppLogger.w('Connexion anonyme réussie : ${user.id}');
      return UserModel(id: user.id);
    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException : $e');
      rethrow;
    } catch (e) {
      AppLogger.e('Erreur inattendue : $e');
      throw AuthException("Erreur lors de la connexion anonyme : $e");
    }
  }

  @override
  Future<void> signOut() async {
    AppLogger.w('Déconnexion');
    try {
      await client.auth.signOut();
      AppLogger.w('Déconnexion réussie');
    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException lors de la déconnexion : $e');
      rethrow;
    } catch (e) {
      AppLogger.e('Erreur inattendue lors de la déconnexion : $e');
      throw AuthException("Erreur lors de la déconnexion : $e");
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    AppLogger.w('Récupération de l\'utilisateur courant');
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        AppLogger.w('Aucun utilisateur connecté');
        return null;
      }
      AppLogger.w('Utilisateur courant : ${user.id}');
      return UserModel(
        id: user.id,
        email: user.email,
      );
    } catch (e) {
      AppLogger.e('Erreur lors de la récupération de l\'utilisateur courant : $e');
      throw AuthException("Erreur lors de la récupération de l'utilisateur courant : $e");
    }
  }
}