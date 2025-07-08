import '../entities/user.dart';
import '../repository/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  Future<User?> call() {
    return repository.getCurrentUser();
  }
} 