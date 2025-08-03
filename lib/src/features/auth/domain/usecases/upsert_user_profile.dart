import 'package:dukoavote/src/core/core.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';
import '../repository/auth_repository.dart';

/// Use case for updating user profile information
class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  /// Updates user profile with the provided information
  Future<Either<Failure, User>> call({
    required Map<String, dynamic> data,
  }) {
    return repository.updateProfile(data: data);
  }
}

/// Use case for checking if user profile is complete
class HasCompleteProfile {
  final AuthRepository repository;

  HasCompleteProfile(this.repository);

  /// Checks if the current user has a complete profile
  Future<Either<Failure, bool>> call() {
    return repository.hasCompleteProfile();
  }
} 