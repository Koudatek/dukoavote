import 'package:dukoavote/src/core/core.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

/// Use case for signing in with Apple
class SignInWithApple {
  final AuthRepository repository;

  SignInWithApple(this.repository);

  /// Signs in a user with Apple OAuth and optional profile data
  Future<Either<Failure, User>> call({
    Map<String, dynamic>? data,
  }) {
    return repository.signInWithApple(data: data);
  }
} 