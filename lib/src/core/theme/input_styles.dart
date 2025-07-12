import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'text_styles.dart';

class AppInputStyles {
  // Style standard
  static InputDecoration get standard => InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.progressBackground),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.progressBackground),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.danger, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.danger, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
  );

  // Style avec icône
  static InputDecoration withIcon(IconData icon) => standard.copyWith(
    prefixIcon: Icon(icon, color: AppColors.textSecondary),
  );

  // Style pour email
  static InputDecoration get email => withIcon(Icons.email).copyWith(
    labelText: 'Email',
    hintText: 'exemple@email.com',
  );

  // Style pour mot de passe
  static InputDecoration get password => withIcon(Icons.lock).copyWith(
    labelText: 'Mot de passe',
    hintText: '••••••••',
  );

  // Style pour nom d'utilisateur
  static InputDecoration get username => withIcon(Icons.person).copyWith(
    labelText: 'Nom d\'utilisateur',
    hintText: 'Votre nom d\'utilisateur',
  );

  // Style pour recherche
  static InputDecoration get search => standard.copyWith(
    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
    hintText: 'Rechercher...',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: AppColors.progressBackground),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: AppColors.progressBackground),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  // Style compact
  static InputDecoration get compact => standard.copyWith(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
  );
} 