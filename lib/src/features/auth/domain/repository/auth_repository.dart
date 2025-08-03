import 'package:dukoavote/src/core/core.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';


abstract interface class AuthRepository {
  /// Signs in a user with email and password
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs up a new user with email, password and optional profile data
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  });

  /// Signs in a user with Google OAuth and optional profile data
  Future<Either<Failure, User>> signInWithGoogle({
    Map<String, dynamic>? data,
  });

  /// Signs in a user with Apple OAuth and optional profile data
  Future<Either<Failure, User>> signInWithApple({
    Map<String, dynamic>? data,
  });

  /// Signs out the current user
  Future<Either<Failure, Unit>> signOut();

  /// Gets the current authenticated user
  Future<Either<Failure, User>> getCurrentUser();

  /// Updates user profile information
  Future<Either<Failure, User>> updateProfile({
    required Map<String, dynamic> data,
  });

  /// Checks if the current user has a complete profile
  Future<Either<Failure, bool>> hasCompleteProfile();

  /// Checks if a username is available
  Future<Either<Failure, bool>> checkUsernameAvailability(String username);
} 