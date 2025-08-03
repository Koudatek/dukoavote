import 'package:flutter/material.dart';

/// Couleurs spécifiques pour l'onboarding avec palette vibrante
class OnboardingColors {
  // Page 1 : "Pose ta Question" - Énergie & Mystère
  static const Color page1Top = Color(0xFFFF6B35); // Orange vif
  static const Color page1Bottom = Color(0xFF1A1A1A); // Noir profond
  
  // Page 2 : "Découvre les Avis" - Découverte & Profondeur
  static const Color page2Top = Color(0xFF4ECDC4); // Cyan vibrant
  static const Color page2Bottom = Color(0xFF2C3E50); // Bleu nuit
  
  // Page 3 : "Ta Voix Compte" - Optimisme & Sagesse
  static const Color page3Top = Color(0xFFFFE66D); // Jaune soleil
  static const Color page3Bottom = Color(0xFF34495E); // Gris bleuté
  
  // Page 4 : "Prêt à Participer" - Passion & Authenticité
  static const Color page4Top = Color(0xFFFF6B9D); // Rose passion
  static const Color page4Bottom = Color(0xFF2C1810); // Brun chaud
  
  // Couleurs utilitaires pour l'onboarding
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xE6FFFFFF); // Blanc avec 90% d'opacité
  static const Color textTertiary = Color(0xCCFFFFFF); // Blanc avec 80% d'opacité
  
  // Couleurs pour les boutons
  static const Color buttonPrimary = Colors.white;
  static const Color buttonSecondary = Color(0x33FFFFFF); // Blanc avec 20% d'opacité
  static const Color buttonTextPrimary = Color(0xFF1A1A1A);
  static const Color buttonTextSecondary = Colors.white;
  
  // Couleurs pour les indicateurs
  static const Color indicatorActive = Colors.white;
  static const Color indicatorCompleted = Color(0x99FFFFFF); // Blanc avec 60% d'opacité
  static const Color indicatorInactive = Color(0x4DFFFFFF); // Blanc avec 30% d'opacité
  
  // Couleurs pour les effets
  static const Color shadow = Color(0x1A000000); // Noir avec 10% d'opacité
  static const Color overlay = Color(0x80000000); // Noir avec 50% d'opacité
  static const Color border = Color(0x4DFFFFFF); // Blanc avec 30% d'opacité
  
  /// Obtenir les couleurs pour une page spécifique
  static List<Color> getPageColors(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return [page1Top, page1Bottom];
      case 1:
        return [page2Top, page2Bottom];
      case 2:
        return [page3Top, page3Bottom];
      case 3:
        return [page4Top, page4Bottom];
      default:
        return [page1Top, page1Bottom];
    }
  }
  
  /// Obtenir la couleur supérieure pour une page
  static Color getTopColor(int pageIndex) {
    return getPageColors(pageIndex)[0];
  }
  
  /// Obtenir la couleur inférieure pour une page
  static Color getBottomColor(int pageIndex) {
    return getPageColors(pageIndex)[1];
  }
  
  /// Créer un gradient pour une page
  static LinearGradient getPageGradient(int pageIndex) {
    final colors = getPageColors(pageIndex);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    );
  }
  
  /// Créer un gradient radial pour les effets spéciaux
  static RadialGradient getRadialGradient(int pageIndex) {
    final colors = getPageColors(pageIndex);
    return RadialGradient(
      center: Alignment.topCenter,
      radius: 1.5,
      colors: [
        colors[0].withOpacity(0.8),
        colors[1].withOpacity(0.6),
        colors[1],
      ],
    );
  }
} 