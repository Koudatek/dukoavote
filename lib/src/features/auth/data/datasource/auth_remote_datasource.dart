import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dukoavote/src/core/core.dart';
import '../models/user_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Remote datasource for authentication operations
/// Uses Either for functional error handling
abstract interface class AuthRemoteDatasource {
  /// Signs in a user with email and password
  Future<Either<Failure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs up a new user with email, password and optional profile data
  Future<Either<Failure, UserModel>> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  });

  /// Signs in a user with Google OAuth and optional profile data
  Future<Either<Failure, UserModel>> signInWithGoogle({
    Map<String, dynamic>? data,
  });

  /// Signs in a user with Apple OAuth and optional profile data
  Future<Either<Failure, UserModel>> signInWithApple({
    Map<String, dynamic>? data,
  });

  /// Signs out the current user
  Future<Either<Failure, Unit>> signOut();

  /// Gets the current authenticated user
  Future<Either<Failure, UserModel>> getCurrentUser();

  /// Updates user profile information
  Future<Either<Failure, UserModel>> updateProfile({
    required Map<String, dynamic> data,
  });

  /// Checks if the current user has a complete profile
  Future<Either<Failure, bool>> hasCompleteProfile();

  /// Checks if a username is available
  Future<Either<Failure, bool>> checkUsernameAvailability(String username);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient client;

  AuthRemoteDatasourceImpl(this.client);

  @override
  Future<Either<Failure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    AppLogger.w('Tentative de connexion avec email');
    try {
      final response = await client.auth.signInWithPassword(
        email: email, 
        password: password
      );
      final user = response.user;
      if (user == null) {
        return left(const AuthFailure('Identifiants invalides'));
      }
      
      AppLogger.w('Connexion réussie : ${user.id}');
      
      // Récupérer les données du profil depuis userMetadata
      final userMetadata = user.userMetadata ?? {};
      final userModel = UserModel.fromMap({
        'id': user.id,
        'email': user.email,
        'username': userMetadata['username'],
        'role': userMetadata['role'],
        'age': userMetadata['age'],
        'gender': userMetadata['gender'],
        'country': userMetadata['country'],
        'city': userMetadata['city'],
        'birth_date': userMetadata['birth_date'],
      });
      
      return right(userModel);
    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException : $e');
      return left(ErrorHandler.handle(e));
    } catch (e) {
      AppLogger.e('Erreur inattendue : $e');
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    AppLogger.w('Inscription avec email/password: $email');
    try {
      // Validation locale de l'email
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        AppLogger.e('Email invalide selon la validation locale: $email');
        return left(const AuthFailure('Format d\'email invalide'));
      }

      // Validation du mot de passe (Supabase exige au moins 6 caractères)
      if (password.length < 6) {
        AppLogger.e('Mot de passe trop court: ${password.length} caractères');
        return left(const AuthFailure('Le mot de passe doit contenir au moins 6 caractères'));
      }

      // Préparer les données par défaut
      final signUpData = <String, dynamic>{
        'role': 'user',
        ...?data, // Spread operator pour ajouter les données optionnelles
      };

      AppLogger.w('Données d\'inscription: $signUpData');

      final response = await client.auth.signUp(
          email: email,
          password: password,
        data: signUpData,
      );
      final user = response.user;
      if (user == null) {
        return left(const AuthFailure('Impossible de créer l\'utilisateur'));
      }

      AppLogger.w('Inscription réussie : ${user.id}');
      
      // Récupérer les données du profil depuis userMetadata
      final userMetadata = user.userMetadata ?? {};
      final userModel = UserModel.fromMap({
        'id': user.id,
        'email': user.email,
        'username': userMetadata['username'],
        'role': userMetadata['role'],
        'age': userMetadata['age'],
        'gender': userMetadata['gender'],
        'country': userMetadata['country'],
        'city': userMetadata['city'],
        'birth_date': userMetadata['birth_date'],
      });
      
      return right(userModel);
    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException : $e');
      AppLogger.e('Code d\'erreur : ${e.code}');
      AppLogger.e('Message d\'erreur : ${e.message}');
      AppLogger.e('Status code : ${e.statusCode}');
      return left(ErrorHandler.handle(e));
    } catch (e) {
      AppLogger.e('Erreur inattendue : $e');
      return left(ErrorHandler.handle(e));
    }
  }



  @override
  Future<Either<Failure, UserModel>> signInWithGoogle({
    Map<String, dynamic>? data,
  }) async {
    AppLogger.w('Tentative de connexion avec Google');
    try {
      // Configuration Google Sign-In
      const webClientId = '<web client ID that you registered on Google Cloud, for example my-web.apps.googleusercontent.com>';
      const iosClientId = '<iOS client ID that you registered on Google Cloud, for example my-ios.apps.googleusercontent.com>';

      // Initialiser Google Sign-In avec la nouvelle API
      await GoogleSignIn.instance.initialize(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      // Utiliser Supabase OAuth direct pour Google (plus simple avec la nouvelle API)
      final response = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );

      // Pour l'instant, on retourne une erreur car l'OAuth nécessite une redirection
      // Dans une vraie implémentation, on gérerait le callback
      return left(const AuthFailure('OAuth Google nécessite une redirection - à implémenter'));

    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException Google : $e');
      return left(ErrorHandler.handle(e));
    } catch (e) {
      AppLogger.e('Erreur inattendue Google : $e');
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithApple({
    Map<String, dynamic>? data,
  }) async {
    AppLogger.w('Tentative de connexion avec Apple');
    //TODO: Implementer la connexion avec Apple
    return left(const AuthFailure('Connexion Apple à implémenter'));
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    AppLogger.w('Déconnexion');
    try {
      // Déconnecter de Supabase
      await client.auth.signOut();
      
      AppLogger.w('Déconnexion réussie');
      return right(unit);
    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException lors de la déconnexion : $e');
      return left(ErrorHandler.handle(e));
    } catch (e) {
      AppLogger.e('Erreur inattendue lors de la déconnexion : $e');
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    AppLogger.w('Récupération de l\'utilisateur courant');
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        AppLogger.w('Aucun utilisateur connecté');
        return left(const AuthFailure('Aucun utilisateur connecté'));
      }
      
      // Les données sont directement dans user.userMetadata
      final userMetadata = user.userMetadata ?? {};
      
      final userModel = UserModel.fromMap({
        'id': user.id,
        'email': user.email,
        'username': userMetadata['username'],
        'role': userMetadata['role'],
        'age': userMetadata['age'],
        'gender': userMetadata['gender'],
        'country': userMetadata['country'],
        'city': userMetadata['city'],
        'birth_date': userMetadata['birth_date'],
      });
      
      return right(userModel);
    } catch (e) {
      AppLogger.e('Erreur lors de la récupération de l\'utilisateur courant : $e');
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    AppLogger.w('Mise à jour du profil utilisateur');
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        return left(const AuthFailure('Aucun utilisateur connecté'));
      }

      // Validation des données si elles sont présentes
      if (data['age'] != null) {
        final int? parsedAge = int.tryParse(data['age'].toString());
        if (parsedAge == null) {
          return left(const AuthFailure('L\'âge doit être un nombre entier'));
        }
        data['age'] = parsedAge;
      }

      if (data['birth_date'] != null) {
        final DateTime? parsedDate = DateTime.tryParse(data['birth_date'].toString());
        if (parsedDate == null) {
          return left(const AuthFailure('La date de naissance doit être au format AAAA-MM-JJ'));
        }
        data['birth_date'] = parsedDate.toIso8601String().split('T').first;
      }

      // Ajouter le rôle par défaut si pas présent
      if (!data.containsKey('role')) {
        data['role'] = 'user';
      }

      final response = await client.auth.updateUser(
        UserAttributes(data: data),
      );

      final updatedUser = response.user;
      if (updatedUser == null) {
        return left(const AuthFailure('Impossible de mettre à jour le profil'));
      }

      AppLogger.w('Profil utilisateur mis à jour avec succès');

      // Récupérer les données mises à jour
      final userMetadata = updatedUser.userMetadata ?? {};
      final userModel = UserModel.fromMap({
        'id': updatedUser.id,
        'email': updatedUser.email,
        'username': userMetadata['username'],
        'role': userMetadata['role'],
        'age': userMetadata['age'],
        'gender': userMetadata['gender'],
        'country': userMetadata['country'],
        'city': userMetadata['city'],
        'birth_date': userMetadata['birth_date'],
      });

      return right(userModel);
    } on AuthException catch (e) {
      AppLogger.e('Erreur AuthException lors de la mise à jour du profil : $e');
      return left(ErrorHandler.handle(e));
    } catch (e) {
      AppLogger.e('Erreur inattendue lors de la mise à jour du profil : $e');
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> hasCompleteProfile() async {
    AppLogger.w('Vérification de la complétude du profil');
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        return left(const AuthFailure('Aucun utilisateur connecté'));
      }

      final userMetadata = user.userMetadata ?? {};
      
      // Vérifier si tous les champs requis sont présents
      final hasCompleteProfile = userMetadata['age'] != null &&
          userMetadata['gender'] != null &&
          userMetadata['country'] != null &&
          userMetadata['city'] != null &&
          userMetadata['birth_date'] != null;

      AppLogger.w('Profil complet: $hasCompleteProfile');
      return right(hasCompleteProfile);
    } catch (e) {
      AppLogger.e('Erreur lors de la vérification du profil : $e');
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUsernameAvailability(String username) async {
    AppLogger.w('Vérification de la disponibilité du nom d\'utilisateur: $username');
    try {
      // Vérifier dans la table users si le nom d'utilisateur existe déjà
      final response = await client
          .from('users')
          .select('username')
          .eq('username', username)
          .limit(1);

      final isAvailable = response.isEmpty;
      AppLogger.w('Nom d\'utilisateur $username disponible: $isAvailable');
      
      return right(isAvailable);
    } catch (e) {
      AppLogger.e('Erreur inattendue lors de la vérification du nom d\'utilisateur: $e');
      return left(ErrorHandler.handle(e));
    }
  }
}