import 'package:dukoavote/src/core/core.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

/// Use case for getting current user
class GetCurrentUser {
  final AuthRepository repository;
  
  GetCurrentUser(this.repository);

  /// Gets the current authenticated user
  Future<Either<Failure, User>> call() {
    return repository.getCurrentUser();
  }
} 