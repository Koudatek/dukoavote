import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingIntroPage extends StatelessWidget {
  const OnboardingIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          //color: AppColors.background,
          padding: const EdgeInsets.only(top: 70),
          child: Text(
            "Bienvenue sur DukoaVote ! Chaque jour, donnez votre avis sur la question du jour.",
            softWrap: true,
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Lottie.asset('assets/animations/salut.json', height: 180),
      ],
    );
  }
}
