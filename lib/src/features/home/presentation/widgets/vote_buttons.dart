import 'package:dukoavote/src/core/core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../vote/domain/entities/vote.dart';
import '../../../vote/presentation/providers/vote_provider.dart';

class VoteButtons extends ConsumerStatefulWidget {
  final String pollId;
  final String userId;
  final List<String> options;

  const VoteButtons({
    super.key,
    required this.pollId,
    required this.userId,
    required this.options,
  });

  @override
  ConsumerState<VoteButtons> createState() => _VoteButtonsState();
}

class _VoteButtonsState extends ConsumerState<VoteButtons> {
  @override
  void initState() {
    super.initState();
    // Charger les votes pour ce sondage au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId.isNotEmpty) {
        ref.read(voteProvider.notifier).loadVotes(widget.pollId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final votes = ref.watch(voteProvider);
    Vote? myVote;
    try {
      myVote = votes.firstWhere((v) => v.pollId == widget.pollId && v.userId == widget.userId);
    } catch (_) {
      myVote = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Votre réponse :',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        ...widget.options.map((option) => _buildVoteButton(context, ref, option, myVote)),
      ],
    );
  }

  Widget _buildVoteButton(BuildContext context, WidgetRef ref, String option, Vote? myVote) {
    final isSelected = myVote?.optionIndex == widget.options.indexOf(option);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            elevation: isSelected ? 4 : 2,
          shadowColor: Colors.black.withAlpha((0.1 * 255).toInt()),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
          ),
        ),
        onPressed: () async {
          if (widget.userId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vous devez être connecté pour voter')),
            );
            return;
          }
          
          // Feedback visuel immédiat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Vote en cours...'),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          
          try {
          final notifier = ref.read(voteProvider.notifier);
          await notifier.vote(
            Vote(
              id: '', // Laisse vide, généré côté backend
                pollId: widget.pollId,
                userId: widget.userId,
                optionIndex: widget.options.indexOf(option),
              createdAt: DateTime.now(),
            ),
          );
            
            // Feedback de succès
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text('Vote enregistré !'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            // Feedback d'erreur
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Erreur: ${e.toString().length > 50 ? '${e.toString().substring(0, 50)}...' : e.toString()}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? Colors.white.withAlpha((0.2 * 255).toInt())
                  : AppColors.primary.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.how_to_vote,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
} 