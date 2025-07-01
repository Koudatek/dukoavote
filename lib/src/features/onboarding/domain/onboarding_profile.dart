class OnboardingProfile {
  final String? gender;
  final int? age;

  OnboardingProfile({this.gender, this.age});

  OnboardingProfile copyWith({String? gender, int? age}) {
    return OnboardingProfile(
      gender: gender ?? this.gender,
      age: age ?? this.age,
    );
  }
} 