import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, super.email});

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        email: map['email'] as String?,
      );
} 