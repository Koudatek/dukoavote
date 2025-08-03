import 'package:dukoavote/src/core/core.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

/// Use case for signing in with Google
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  /// Signs in a user with Google OAuth and optional profile data
  Future<Either<Failure, User>> call({
    Map<String, dynamic>? data,
  }) {
    return repository.signInWithGoogle(data: data);
  }
} 