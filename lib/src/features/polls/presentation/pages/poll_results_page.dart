import 'package:dukoavote/src/core/ui/feedback_service.dart';
import 'package:dukoavote/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dukoavote/src/core/core.dart';
import '../../domain/entities/poll.dart';
import 'package:dukoavote/src/features/home/presentation/widgets/vote_buttons.dart';
import 'package:dukoavote/src/features/vote/presentation/widgets/vote_results.dart';
import '../../../vote/presentation/providers/vote_provider.dart';

class PollResultsPage extends ConsumerStatefulWidget {
  final Poll poll;
  final String userId;

  const PollResultsPage({
    super.key,
    required this.poll,
    required this.userId,
  });

  @override
  ConsumerState<PollResultsPage> createState() => _PollResultsPageState();
}

class _PollResultsPageState extends ConsumerState<PollResultsPage> {
  @override
  void initState() {
    super.initState();
    // Charger les votes pour ce sondage au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voteProvider.notifier).loadVotes(widget.poll.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPollOpen = !widget.poll.isClosed && now.isBefore(widget.poll.endDate);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Résultats du sondage',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête du sondage
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statut du sondage
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPollOpen ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPollOpen ? Icons.access_time : Icons.check_circle,
                            size: 16,
                            color: isPollOpen ? Colors.green[700] : Colors.red[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPollOpen ? 'En cours' : 'Terminé',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isPollOpen ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Question
                    Text(
                      widget.poll.question,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Informations temporelles
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Du ${_formatDateTime(widget.poll.startDate)} au ${_formatDateTime(widget.poll.endDate)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (isPollOpen) ...[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('Fermer le sondage'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final reason = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                String? input;
                                return AlertDialog(
                                  title: const Text('Raison de la fermeture'),
                                  content: TextField(
                                    autofocus: true,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: 'Expliquez pourquoi vous fermez ce sondage...',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) => input = value,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (input != null && input!.trim().isNotEmpty) {
                                          Navigator.of(context).pop(input!.trim());
                                        }
                                      },
                                      child: const Text('Fermer'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (reason != null && reason.isNotEmpty) {
                              try {
                                await ref.read(pollRepositoryProvider).closePoll(widget.poll.id!, closedReason: reason);
                                if (context.mounted) {
                                  FeedbackService.showSuccess(context, 'Sondage fermé avec succès.');
                                  Navigator.of(context).pop(); // Revenir à la liste
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  FeedbackService.showError(context, 'Erreur lors de la fermeture : $e');
                                }
                              }
                            } else {
                              if (context.mounted) {
                                FeedbackService.showInfo(context, 'Merci de saisir une raison pour fermer le sondage.');
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Section de vote (si le sondage est ouvert)
              if (isPollOpen) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voter',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Message si l'utilisateur n'est pas connecté
                      if (widget.userId.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Vous devez être connecté pour voter',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      VoteButtons(
                        pollId: widget.poll.id!,
                        userId: widget.userId,
                        options: widget.poll.options,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Section d'information si le sondage n'est pas ouvert
              if (!isPollOpen) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sondage fermé',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.poll.closedReason != null && widget.poll.closedReason!.trim().isNotEmpty
                          ? widget.poll.closedReason!
                          : 'Sondage terminé (fin du temps imparti).',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Section des résultats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: VoteResults(
                  pollId: widget.poll.id!,
                  options: widget.poll.options,
                  isClosed: widget.poll.isClosed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 