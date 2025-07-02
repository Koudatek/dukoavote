import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingWhyPage extends StatelessWidget {
  const OnboardingWhyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Text(
            "Vos réponses anonymes contribuent à des statistiques publiques et enrichissent le débat.",
            softWrap: true,
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Lottie.asset('assets/animations/question.json', height: 180),
      ],
    );
  }
} 