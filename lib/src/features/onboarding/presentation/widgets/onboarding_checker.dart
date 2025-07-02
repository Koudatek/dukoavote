import 'package:dukoavote/src/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingChecker extends ConsumerStatefulWidget {
  const OnboardingChecker({super.key});

  @override
  ConsumerState<OnboardingChecker> createState() => _OnboardingCheckerState();
}

class _OnboardingCheckerState extends ConsumerState<OnboardingChecker> {
  bool? _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final hasCompleted = await OnboardingLocalStorage.isOnboardingCompleted();
    setState(() {
      _hasCompletedOnboarding = hasCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCompletedOnboarding == null) {
      // Affiche un écran blanc pendant la récupération
      return const SizedBox.shrink();
    }

    if (_hasCompletedOnboarding!) {
      return const MainApp();
    } else {
      return const OnboardingScreen();
    }
  }
} 