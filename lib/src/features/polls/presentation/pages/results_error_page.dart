import 'package:dukoavote/src/core/core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ResultsErrorPage extends StatelessWidget {
  final String? pollId;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ResultsErrorPage({
    super.key,
    this.pollId,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Résultats',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône d'erreur
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Titre
                Text(
                  _getTitle(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Message d'erreur
                Text(
                  _getMessage(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (pollId != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ID: $pollId',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Bouton Retour
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Retour'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Bouton Réessayer
                    if (onRetry != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Lien vers l'accueil
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Retour à l\'accueil',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    if (pollId == null || pollId!.isEmpty) {
      return 'Aucun sondage sélectionné';
    }
    
    if (errorMessage != null && errorMessage!.contains('introuvable')) {
      return 'Sondage introuvable';
    }
    
    if (errorMessage != null && errorMessage!.contains('accès')) {
      return 'Accès refusé';
    }
    
    return 'Erreur de chargement';
  }

  String _getMessage() {
    if (pollId == null || pollId!.isEmpty) {
      return 'Aucun sondage n\'a été sélectionné pour afficher les résultats. Veuillez sélectionner un sondage depuis la liste.';
    }
    
    if (errorMessage != null && errorMessage!.contains('introuvable')) {
      return 'Le sondage demandé n\'existe pas ou a été supprimé. Veuillez vérifier l\'identifiant ou retourner à la liste des sondages.';
    }
    
    if (errorMessage != null && errorMessage!.contains('accès')) {
      return 'Vous n\'avez pas les permissions nécessaires pour voir les résultats de ce sondage.';
    }
    
    if (errorMessage != null) {
      return errorMessage!;
    }
    
    return 'Impossible de charger les résultats du sondage. Veuillez vérifier votre connexion et réessayer.';
  }
} 