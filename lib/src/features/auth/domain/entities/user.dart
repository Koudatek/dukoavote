import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String? username;
  final String? role;
  final int? age;
  final String? gender;
  final String? country;
  final String? city;
  final String? birthDate;
  final bool isProfileComplete;

  const User({
    required this.id,
    this.email,
    this.username,
    this.role,
    this.age,
    this.gender,
    this.country,
    this.city,
    this.birthDate,
    this.isProfileComplete = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? role,
    int? age,
    String? gender,
    String? country,
    String? city,
    String? birthDate,
    bool? isProfileComplete,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      birthDate: birthDate ?? this.birthDate,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  /// Checks if the user profile is complete
  bool get hasCompleteProfile {
    return age != null && 
           gender != null && 
           country != null && 
           city != null && 
           birthDate != null;
  }

  @override
  List<Object?> get props => [
    id, 
    email, 
    username, 
    role, 
    age, 
    gender, 
    country, 
    city, 
    birthDate, 
    isProfileComplete
  ];
} 