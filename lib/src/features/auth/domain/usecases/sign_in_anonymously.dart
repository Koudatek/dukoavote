import '../entities/user.dart';
import '../repository/auth_repository.dart';

class SignInAnonymously {
  final AuthRepository repository;
  SignInAnonymously(this.repository);

  Future<User?> call(String gender, String birthDate, String age) {
    return repository.signInAnonymously(gender, birthDate, age);
  }
} 