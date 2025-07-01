import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingPrivacyPage extends StatelessWidget {
  const OnboardingPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          //color: AppColors.background,
          padding: EdgeInsets.only(top: 70,),
          child: Text(
            "Votre vote est totalement anonyme. Personne ne saura ce que vous avez répondu.",
            softWrap: true,
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Lottie.asset('assets/animations/privacy.json', height: 180),
      ],
    );
  }
} 