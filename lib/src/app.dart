
import 'package:dukoavote/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';

class DukoaVoteApp extends StatelessWidget {
  const DukoaVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "DukoaVote",
      home: OnboardingScreen(),
    );
  }
}


