import 'package:dukoavote/src/core/core.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

/// Use case for signing up with email and password
class SignUpWithEmail {
  final AuthRepository repository;
  
  SignUpWithEmail(this.repository);

  /// Signs up a new user with email, password and optional profile data
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return repository.signUpWithEmail(
      email: email,
      password: password,
      data: data,
    );
  }
} 