import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/utils/app_logger.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel?> signInWithEmail(String email, String password);
  Future<UserModel?> signUpWithEmail(String email, String password, String username);
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
  Future<UserModel?> signUpWithEmail(String email, String password, String username) async {
    AppLogger.w('Migration d\'un compte anonyme vers email/password avec username: $username');
    try {
      // Mettre à jour l'utilisateur Auth (migration anonyme -> email/password)
      final updateResponse = await client.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
        ),
      );
      final user = updateResponse.user;
      if (user == null) throw AuthException("Impossible de migrer le compte anonyme.");

      // Mettre à jour la ligne existante dans users (ajout username, passage role à 'user')
      try {
        await client.from('users').update({
          'username': username,
          'role': 'user',
        }).eq('id', user.id);
        AppLogger.w('Profil utilisateur mis à jour (guest -> user) avec succès');
      } catch (dbError) {
        AppLogger.e('Erreur lors de la mise à jour du profil utilisateur : $dbError');
        throw AuthException("Erreur lors de la mise à jour du profil utilisateur");
      }

      AppLogger.w('Migration réussie : \\${user.id} avec username: $username');
      return UserModel(id: user.id, email: user.email, username: username, role: 'user');
    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException : $e');
      rethrow;
    } catch (e) {
      AppLogger.e('Erreur inattendue : $e');
      throw AuthException("Erreur lors de la migration : $e");
    }
  }

  @override
  Future<UserModel?> signInAnonymously(String gender, String birthDate, String age) async {
    AppLogger.w('Connexion anonyme');
    try {
      // Validation côté Flutter
      final int? parsedAge = int.tryParse(age);
      if (parsedAge == null) {
        throw AuthException("L'âge doit être un nombre entier.");
      }
      // birthDate doit être au format YYYY-MM-DD
      final DateTime? parsedDate = DateTime.tryParse(birthDate);
      if (parsedDate == null) {
        throw AuthException("La date de naissance doit être au format AAAA-MM-JJ.");
      }
      final String formattedBirthDate = parsedDate.toIso8601String().split('T').first;

      final response = await client.auth.signInAnonymously();
      final user = response.user;
      if (user == null) throw AuthException("Impossible de créer un utilisateur anonyme.");

      // Créer ou mettre à jour l'enregistrement dans la table users
      try {
        await client.from('users').upsert({
          'id': user.id,
          'gender': gender,
          'birth_date': formattedBirthDate,
          'age': parsedAge,
          'role': 'guest',
          'username': null,
        });
        AppLogger.w('Enregistrement utilisateur guest créé/mis à jour avec succès');
      } catch (dbError) {
        AppLogger.e('Erreur lors de la création/mise à jour de l\'enregistrement utilisateur guest : $dbError');
        throw AuthException("Erreur lors de la création du profil utilisateur guest");
      }

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
      
      // Récupérer les infos de la table users
      final data = await client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      
      // Combiner les données de l'auth (email) avec celles de la table users
      return UserModel(
        id: user.id,
        email: user.email,
        username: data['username'],
        role: data['role'],
      );
    } catch (e) {
      AppLogger.e('Erreur lors de la récupération de l\'utilisateur courant : $e');
      throw AuthException("Erreur lors de la récupération de l'utilisateur courant : $e");
    }
  }
}