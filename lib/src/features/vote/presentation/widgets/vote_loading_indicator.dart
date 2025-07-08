import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoteLoadingIndicator extends StatelessWidget {
  final String message;

  const VoteLoadingIndicator({
    super.key,
    this.message = 'Chargement des votes...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animation de chargement
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cercle de fond
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                ),
                // Indicateur de progression
                CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                // Icône de vote au centre
                Icon(
                  Icons.how_to_vote,
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  size: 24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Message
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Sous-message
          Text(
            'Veuillez patienter...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 