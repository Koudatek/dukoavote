import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_vote_statistics.dart';
import '../providers/vote_provider.dart';
import 'vote_loading_indicator.dart';

class VoteResults extends ConsumerStatefulWidget {
  final String pollId;
  final List<String> options;
  final bool isClosed;

  const VoteResults({
    super.key,
    required this.pollId,
    required this.options,
    required this.isClosed,
  });

  @override
  ConsumerState<VoteResults> createState() => _VoteResultsState();
}

class _VoteResultsState extends ConsumerState<VoteResults>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final votes = ref.watch(voteProvider);
    final pollVotes = votes.where((v) => v.pollId == widget.pollId).toList();
    
    return FutureBuilder<VoteStatistics>(
      future: GetVoteStatistics()(pollVotes, widget.options.length),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const VoteLoadingIndicator(
            message: 'Calcul des résultats...',
          );
        }
        
        if (!snapshot.hasData) {
          return const VoteLoadingIndicator(
            message: 'Aucune donnée disponible',
          );
        }

        final stats = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête des résultats
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Résultats',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stats.totalVotes} vote${stats.totalVotes > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Affichage du gagnant (si applicable)
            if (stats.winningOptionIndex != null && stats.totalVotes > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber[100]!,
                      Colors.amber[50]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🏆 Option majoritaire : ${widget.options[stats.winningOptionIndex!]}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Barres de progression pour chaque option
            ...widget.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final votesForOption = stats.votesPerOption[index] ?? 0;
              final percentage = stats.percentagesPerOption[index] ?? 0.0;
              final isWinner = stats.winningOptionIndex == index;
              
                              return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: isWinner ? const EdgeInsets.all(8) : EdgeInsets.zero,
                  decoration: isWinner ? BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ) : null,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texte de l'option avec pourcentage
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                option,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: isWinner ? FontWeight.w600 : FontWeight.w500,
                                  color: isWinner ? Colors.amber[800] : Colors.grey[800],
                                ),
                              ),
                              if (isWinner) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.emoji_events,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                                         // Barre de progression améliorée
                     Container(
                       height: 12,
                       decoration: BoxDecoration(
                         color: Colors.grey[200],
                         borderRadius: BorderRadius.circular(6),
                       ),
                       child: Stack(
                         children: [
                           AnimatedBuilder(
                             animation: _animation,
                             builder: (context, child) {
                               return FractionallySizedBox(
                                 alignment: Alignment.centerLeft,
                                 widthFactor: (percentage / 100) * _animation.value,
                                 child: Container(
                                   decoration: BoxDecoration(
                                     gradient: LinearGradient(
                                       colors: [
                                         Theme.of(context).primaryColor,
                                         Theme.of(context).primaryColor.withOpacity(0.8),
                                       ],
                                     ),
                                     borderRadius: BorderRadius.circular(6),
                                   ),
                                 ),
                               );
                             },
                           ),
                           // Indicateur de pourcentage sur la barre
                           if (percentage > 15)
                             Positioned(
                               right: 8,
                               top: 0,
                               bottom: 0,
                               child: Center(
                                 child: Text(
                                   '${percentage.toStringAsFixed(0)}%',
                                   style: GoogleFonts.poppins(
                                     fontSize: 10,
                                     fontWeight: FontWeight.w600,
                                     color: Colors.white,
                                   ),
                                 ),
                               ),
                             ),
                         ],
                       ),
                     ),
                    
                    // Nombre de votes
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$votesForOption vote${votesForOption > 1 ? 's' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            // Message si aucun vote
            if (stats.totalVotes == 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aucun vote pour le moment',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
} 