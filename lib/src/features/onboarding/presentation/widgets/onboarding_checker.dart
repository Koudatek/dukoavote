
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dukoavote/src/src.dart';

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
      return const SizedBox.shrink();
    }

    if (_hasCompletedOnboarding!) {
      return const HomeWithNavigation();
    } else {
      return const OnboardingPage();
    }
  }
} 