
import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  });

  Future<Either<Failure, User>> signInWithGoogle({
    Map<String, dynamic>? data,
  });

  Future<Either<Failure, User>> signInWithApple({
    Map<String, dynamic>? data,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, User>> updateProfile({
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, bool>> hasCompleteProfile();

  Future<Either<Failure, bool>> checkUsernameAvailability(String username);
}