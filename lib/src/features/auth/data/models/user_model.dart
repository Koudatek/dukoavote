import '../../domain/entities/user.dart';

/// UserModel extends User entity and adds data layer functionality
/// This follows the repository pattern for data transformation
class UserModel extends User {
  const UserModel({
    required super.id,
    super.email,
    super.username,
    super.role,
    super.age,
    super.gender,
    super.country,
    super.city,
    super.birthDate,
    super.isProfileComplete,
  });

  /// Creates a UserModel from a JSON map (from Supabase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String?,
      username: map['username'] as String?,
      role: map['role'] as String?,
      age: map['age'] as String?,
      gender: map['gender'] as String?,
      country: map['country'] as String?,
      city: map['city'] as String?,
      birthDate: map['birth_date'] as String?,
      isProfileComplete: _checkProfileCompleteness(map),
    );
  }

  /// Creates a UserModel from Supabase Auth user
  factory UserModel.fromSupabaseAuth(Map<String, dynamic> authUser) {
    return UserModel(
      id: authUser['id'] as String,
      email: authUser['email'] as String?,
      username: authUser['user_metadata']?['username'] as String?,
      role: authUser['role'] as String?,
    );
  }

  /// Converts UserModel to a map for Supabase storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'age': age,
      'gender': gender,
      'country': country,
      'city': city,
      'birth_date': birthDate,
    };
  }

  /// Converts UserModel to a map for profile updates
  Map<String, dynamic> toProfileMap() {
    final map = <String, dynamic>{};
    if (age != null) map['age'] = age;
    if (gender != null) map['gender'] = gender;
    if (country != null) map['country'] = country;
    if (city != null) map['city'] = city;
    if (birthDate != null) map['birth_date'] = birthDate;
    if (username != null) map['username'] = username;
    return map;
  }

  /// Checks if profile data is complete
  static bool _checkProfileCompleteness(Map<String, dynamic> map) {
    return map['age'] != null &&
           map['gender'] != null &&
           map['country'] != null &&
           map['city'] != null &&
           map['birth_date'] != null;
  }

  /// Creates a copy with updated profile data
  UserModel copyWithProfile({
    String? age,
    String? gender,
    String? country,
    String? city,
    String? birthDate,
    String? username,
  }) {
    return UserModel(
      id: id,
      email: email,
      role: role,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      birthDate: birthDate ?? this.birthDate,
      username: username ?? this.username,
      isProfileComplete: _checkProfileCompleteness({
        'age': age ?? this.age,
        'gender': gender ?? this.gender,
        'country': country ?? this.country,
        'city': city ?? this.city,
        'birth_date': birthDate ?? this.birthDate,
      }),
    );
  }

  /// Converts UserModel to User entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      role: role,
      age: age,
      gender: gender,
      country: country,
      city: city,
      birthDate: birthDate,
      isProfileComplete: isProfileComplete,
    );
  }
} 