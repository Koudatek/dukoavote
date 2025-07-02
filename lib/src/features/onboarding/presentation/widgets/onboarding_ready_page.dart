import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingReadyPage extends StatelessWidget {
  const OnboardingReadyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Text(
            "C'est parti ! Répondez en un clic et découvrez ce que pense la communauté.",
            softWrap: true,
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Lottie.asset('assets/animations/thumbs-up.json', height: 180),
      ],
    );
  }
} 