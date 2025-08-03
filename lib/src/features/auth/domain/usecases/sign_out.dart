import 'package:dukoavote/src/core/core.dart';
import 'package:fpdart/fpdart.dart';
import '../repository/auth_repository.dart';

/// Use case for signing out
class SignOut {
  final AuthRepository repository;
  
  SignOut(this.repository);

  /// Signs out the current user
  Future<Either<Failure, Unit>> call() {
    return repository.signOut();
  }
} 