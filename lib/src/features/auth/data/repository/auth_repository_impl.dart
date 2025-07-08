import 'package:dukoavote/src/features/auth/domain/entities/user.dart';

import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

 @override
  Future<User?> signInWithEmail(String email, String password) {
    return remoteDatasource.signInWithEmail(email, password);
  }

  @override
  Future<UserModel?> signUpWithEmail(String email, String password) {
    return remoteDatasource.signUpWithEmail(email, password);
  }

  @override
  Future<UserModel?> signInAnonymously(String gender, String birthDate, String age) {
    return remoteDatasource.signInAnonymously(gender, birthDate, age);
  }

  @override
  Future<void> signOut() {
    return remoteDatasource.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() {
    return remoteDatasource.getCurrentUser();
  }

 
} 