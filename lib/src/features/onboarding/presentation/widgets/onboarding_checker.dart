import 'package:dukoavote/src/features/onboarding/domain/onboarding_preferences.dart';
import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';

class OnboardingChecker extends StatefulWidget {
  final Widget child; // L'app principale à afficher si onboarding terminé
  const OnboardingChecker({super.key, required this.child});

  @override
  State<OnboardingChecker> createState() => _OnboardingCheckerState();
}

class _OnboardingCheckerState extends State<OnboardingChecker> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isCompleted = await OnboardingPreferences.isOnboardingCompleted();
    
    setState(() {
      _showOnboarding = !isCompleted;
      _isLoading = false;
    });
  }

  void _onOnboardingFinished() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(onFinish: _onOnboardingFinished);
    }

    return widget.child;
  }
} 