import 'package:dukoavote/src/core/core.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

/// Use case for signing in with email and password
class SignInWithEmail {
  final AuthRepository repository;
  
  SignInWithEmail(this.repository);

  /// Signs in a user with email and password
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
} 