import 'package:dukoavote/src/core/core.dart';
import 'package:dukoavote/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Application principale DukoaVote
/// Gère l'initialisation et la configuration de l'app
class DukoaVoteApp extends ConsumerStatefulWidget {
  const DukoaVoteApp({super.key});

  @override
  ConsumerState<DukoaVoteApp> createState() => _DukoaVoteAppState();
}

class _DukoaVoteAppState extends ConsumerState<DukoaVoteApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialise l'application au démarrage
  Future<void> _initializeApp() async {
    // Charger l'utilisateur connecté au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DukoaVote',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Suit le thème système
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Gestion globale des erreurs
        return _ErrorHandler(child: child);
      },
    );
  }
}

/// Gestionnaire d'erreurs global
class _ErrorHandler extends StatelessWidget {
  final Widget? child;
  
  const _ErrorHandler({this.child});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
} 