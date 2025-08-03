import 'package:equatable/equatable.dart';

/// Entité représentant les données collectées pendant l'onboarding
class OnboardingData extends Equatable {
  final DateTime birthDate;
  final String gender;
  final String country;
  final String username;

  const OnboardingData({
    required this.birthDate,
    required this.gender,
    required this.country,
    required this.username,
  });

  /// Calcule l'âge à partir de la date de naissance
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Convertit en Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'country': country,
      'age': age,
      'username': username,
    };
  }

  /// Crée une instance depuis un Map (pour Supabase)
  factory OnboardingData.fromMap(Map<String, dynamic> map) {
    return OnboardingData(
      birthDate: DateTime.parse(map['birth_date']),
      gender: map['gender'],
      country: map['country'],
      username: map['username'] ?? '',
    );
  }

  @override
  List<Object?> get props => [birthDate, gender, country, username];

  @override
  String toString() {
    return 'OnboardingData(birthDate: $birthDate, gender: $gender, country: $country, username: $username, age: $age)';
  }
} 