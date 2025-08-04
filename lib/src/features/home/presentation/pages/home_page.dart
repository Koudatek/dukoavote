
import 'package:dukoavote/src/src.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Démarrer le rafraîchissement automatique des sondages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(autoRefreshPollsProvider).startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Arrêter le rafraîchissement automatique
    ref.read(autoRefreshPollsProvider).stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pollsAsync = ref.watch(pollsProvider);
    final authState = ref.watch(authProvider);
    
    // Initialiser et programmer les alarmes quand les sondages sont chargés
    pollsAsync.whenData((result) {
      result.fold(
        (failure) {
          // En cas d'erreur, on ne programme pas d'alarmes
          AppLogger.e('Erreur lors du chargement des sondages: ${(failure as Failure).message}');
        },
        (polls) {
          final repo = ref.read(pollRepositoryProvider);
          ref.read(alarmInitializerProvider(repo));
          ref.read(alarmSchedulerProvider(polls));
        },
      );
    });
    
    // Afficher un indicateur de chargement si l'authentification est en cours
    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement de votre session...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'DukoaVote',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              // Navigation vers les stats
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Onboarding',
            onPressed: () async {
              // Réinitialiser complètement l'onboarding
              await OnboardingLocalStorage.resetOnboarding();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Onboarding réinitialisé ! Redirection...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Attendre un peu pour que l'utilisateur voie le message
                await Future.delayed(const Duration(seconds: 2));
                
                if (context.mounted) {
                  // Rediriger vers l'onboarding
                  context.go(RouteNames.onboarding);
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: pollsAsync.when(
          data: (result) => result.fold(
            (failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (failure as Failure).message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            (polls) => polls.isEmpty
                ? const Center(child: Text('Aucun sondage disponible'))
                : ListView.builder(
                    itemCount: polls.length,
                    itemBuilder: (context, index) {
                      final poll = polls[index];
                      final now = DateTime.now();
                      double progress;
                      if (poll.isClosed || now.isAfter(poll.endDate)) {
                        progress = 1.0;
                      } else if (now.isBefore(poll.startDate)) {
                        progress = 0.0;
                      } else {
                        final total = poll.endDate.difference(poll.startDate).inSeconds;
                        final elapsed = now.difference(poll.startDate).inSeconds;
                        progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 1.0;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question du jour',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _formatDateFr(poll.startDate),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: poll.isClosed
                                    ? () {
                                        // Navigation vers la page de résultats
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => PollResultsPage(
                                              poll: poll,
                                              userId: authState.user?.id ?? '',
                                            ),
                                          ),
                                        );
                                      }
                                    : () {
                                        // Affiche une notification informative si le sondage n'est pas fermé
                                        FeedbackService.showInfo(
                                          context,
                                          'Veuillez attendre la fin du sondage pour voir les résultats.',
                                        );
                                      },
                                child: QuestionCard(
                                  question: poll.question,
                                  progress: progress,
                                  isClosed: poll.isClosed,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Boutons de vote (toujours affichés si le sondage est ouvert)
                            if (!poll.isClosed && DateTime.now().isBefore(poll.endDate))
                              VoteButtons(
                                pollId: poll.id!,
                                userId: authState.user?.id ?? '',
                                options: poll.options,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FeedbackService.showError(context, 'Erreur: $e');
            });
            return const Center(child: Text('Erreur lors du chargement des sondages.'));
          },
        ),
      ),
      // FloatingActionButton supprimé car maintenant accessible via la bottom navigation
    );
  }

  String _formatDateFr(DateTime date) {
    // Format simple : 12 juin 2024
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
} 