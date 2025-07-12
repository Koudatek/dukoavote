import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password, String username);
  Future<User?> signInAnonymously(String gender, String birthDate, String age);
  Future<void> signOut();
  Future<User?> getCurrentUser();
} 