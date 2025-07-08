import '../entities/user.dart';
import '../repository/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;
  SignUpWithEmail(this.repository);

  Future<User?> call(String email, String password) {
    return repository.signUpWithEmail(email, password);
  }
} 