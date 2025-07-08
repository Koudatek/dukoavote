import 'package:dukoavote/src/core/core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final double progress; // 0.0 à 1.0
  final bool isClosed;
  
  const QuestionCard({
    super.key,
    required this.question,
    this.progress = 0.7, // valeur par défaut pour la démo
    this.isClosed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha :0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de progression bord à bord, arrondie
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.progressBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                isClosed ? AppColors.danger : AppColors.primary,
              ),
            ),
          ),
          // Le reste du contenu avec padding
          Padding(
            padding: const EdgeInsets.only(bottom: 24, right: 20, left: 20, top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isClosed ? AppColors.danger.withAlpha((0.12 * 255).toInt()) : AppColors.success.withAlpha((0.12 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isClosed ? Icons.lock : Icons.check_circle,
                            size: 16,
                            color: isClosed ? AppColors.danger : AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isClosed ? 'Sondage fermé' : 'Sondage en cours',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isClosed ? AppColors.danger : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isClosed 
                          ? AppColors.danger.withAlpha((0.1 * 255).toInt())
                          : AppColors.primary.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isClosed ? Icons.question_answer_outlined : Icons.question_answer,
                        color: isClosed ? AppColors.danger : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          question,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      isClosed ? Icons.lock_clock : Icons.access_time,
                      size: 16,
                      color: isClosed ? AppColors.danger : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isClosed ? 'Sondage fermé' : 'Question ouverte jusqu\'à 23h59',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isClosed ? AppColors.danger : Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isClosed ? Icons.visibility : Icons.arrow_forward_ios,
                      size: 14,
                      color: isClosed ? AppColors.danger : Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 