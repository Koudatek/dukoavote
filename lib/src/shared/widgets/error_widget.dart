import 'package:flutter/material.dart';
import 'package:dukoavote/src/core/core.dart';

/// Simple error widget for displaying failures
class AppErrorWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.failure,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getErrorColor(failure).withOpacity(0.1),
        border: Border.all(color: _getErrorColor(failure).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(failure),
            color: _getErrorColor(failure),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              failure.message,
              style: TextStyle(color: _getErrorColor(failure)),
            ),
          ),
          if (onRetry != null && failure is NetworkFailure)
            TextButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
        ],
      ),
    );
  }

  Color _getErrorColor(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return Colors.orange;
      case AuthFailure:
        return Colors.red;
      case ValidationFailure:
        return Colors.orange;
      case ServerFailure:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getErrorIcon(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return Icons.wifi_off;
      case AuthFailure:
        return Icons.error_outline;
      case ValidationFailure:
        return Icons.warning_amber;
      case ServerFailure:
        return Icons.error;
      default:
        return Icons.info_outline;
    }
  }
} 