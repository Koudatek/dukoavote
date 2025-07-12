import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String? username;
  final String? role;

  const User({required this.id, this.email, this.username, this.role});

  @override
  List<Object?> get props => [id, email, username, role];
} 