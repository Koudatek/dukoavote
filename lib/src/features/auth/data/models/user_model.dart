import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, super.email, super.username, super.role});

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        email: map['email'] as String?,
        username: map['username'] as String?,
        role: map['role'] as String?,
      );
} 