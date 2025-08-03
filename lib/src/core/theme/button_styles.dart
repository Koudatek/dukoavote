import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'text_styles.dart';

class AppButtonStyles {
  // Bouton principal
  static ButtonStyle get primary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    textStyle: AppTextStyles.buttonMedium,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
  );

  // Bouton secondaire
  static ButtonStyle get secondary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    textStyle: AppTextStyles.buttonMedium,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
  );

  // Bouton danger
  static ButtonStyle get danger => ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    textStyle: AppTextStyles.buttonMedium,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
  );

  // Bouton success
  static ButtonStyle get success => ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    textStyle: AppTextStyles.buttonMedium,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
  );

  // Bouton outline
  static ButtonStyle get outline => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    textStyle: AppTextStyles.buttonMedium.copyWith(color: AppColors.primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.primary, width: 1),
    ),
    elevation: 0,
  );

  // Bouton texte
  static ButtonStyle get text => TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
  );

  // Bouton large
  static ButtonStyle get primaryLarge => primary.copyWith(
    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
    textStyle: WidgetStateProperty.all(AppTextStyles.buttonLarge),
  );

  // Bouton compact
  static ButtonStyle get primaryCompact => primary.copyWith(
    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
    textStyle: WidgetStateProperty.all(AppTextStyles.buttonMedium.copyWith(fontSize: 12)),
  );
} 