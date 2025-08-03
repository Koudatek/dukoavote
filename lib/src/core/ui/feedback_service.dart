import 'package:dukoavote/src/core/core.dart';
import 'package:flutter/material.dart';

class FeedbackService {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green[700]!);
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red[700]!);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.success);
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 