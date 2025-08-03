import 'package:dukoavote/src/core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dukoavote/src/features/auth/domain/entities/user.dart';

import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

/// Implementation of AuthRepository using functional programming principles
/// Converts UserModel to User entity and handles Either types
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await remoteDatasource.signInWithEmail(
      email: email,
      password: password,
    );
    
    return result.map((userModel) => userModel.toEntity());
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final result = await remoteDatasource.signUpWithEmail(
      email: email,
      password: password,
      data: data,
    );
    
    return result.map((userModel) => userModel.toEntity());
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle({
    Map<String, dynamic>? data,
  }) async {
    final result = await remoteDatasource.signInWithGoogle(data: data);
    
    return result.map((userModel) => userModel.toEntity());
  }

  @override
  Future<Either<Failure, User>> signInWithApple({
    Map<String, dynamic>? data,
  }) async {
    final result = await remoteDatasource.signInWithApple(data: data);
    
    return result.map((userModel) => userModel.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    return await remoteDatasource.signOut();
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final result = await remoteDatasource.getCurrentUser();
    
    return result.map((userModel) => userModel.toEntity());
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    final result = await remoteDatasource.updateProfile(data: data);
    
    return result.map((userModel) => userModel.toEntity());
  }

  @override
  Future<Either<Failure, bool>> hasCompleteProfile() async {
    return await remoteDatasource.hasCompleteProfile();
  }

  @override
  Future<Either<Failure, bool>> checkUsernameAvailability(String username) async {
    return await remoteDatasource.checkUsernameAvailability(username);
  }
} 