import '../entities/user.dart';
import '../repository/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;
  SignUpWithEmail(this.repository);

  Future<User?> call(String email, String password, String username) {
    return repository.signUpWithEmail(email, password, username);
  }
} 