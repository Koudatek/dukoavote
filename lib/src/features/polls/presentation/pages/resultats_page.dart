import 'package:dukoavote/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dukoavote/src/core/core.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultsPage extends ConsumerStatefulWidget {
  final String pollId;
  final String userId;

  const ResultsPage({
    super.key,
    required this.pollId,
    required this.userId,
  });

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _chartAnimationController.forward();

          // Charger les votes pour ce sondage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pollId.isNotEmpty) {
          ref.read(voteProvider.notifier).loadVotes(widget.pollId);
        }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Résultats',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResults(),
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.pollId.isEmpty) {
      return _buildEmptyState();
    }

    return FutureBuilder<Poll?>(
      future: _loadPoll(),
      builder: (context, pollSnapshot) {
        if (pollSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!pollSnapshot.hasData || pollSnapshot.data == null) {
          return _buildErrorState();
        }

        final poll = pollSnapshot.data!;
        return _buildResultsContent(poll);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
                    const SizedBox(height: 24),
            Text(
            'Aucun sondage sélectionné',
              style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez un sondage pour voir ses résultats',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
            'Chargement des résultats...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
        child: Padding(
        padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              ),
              const SizedBox(height: 32),
              Text(
              'Erreur de chargement',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
              'Impossible de charger les résultats du sondage',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            if (widget.pollId.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${widget.pollId}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
              const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                  ),
                ),
              ),
            ],
          ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/home'),
          child: Text(
                'Retour à l\'accueil',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildResultsContent(Poll poll) {
    final votes = ref.watch(voteProvider);
    final pollVotes = votes.where((v) => v.pollId == widget.pollId).toList();
    
    return FutureBuilder<VoteStatistics>(
      future: GetVoteStatistics()(pollVotes, poll.options.length),
      builder: (context, statsSnapshot) {
        if (statsSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!statsSnapshot.hasData) {
          return _buildErrorState();
        }

        final stats = statsSnapshot.data!;
        
        return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              _buildPollHeader(poll),
                    const SizedBox(height: 24),
              _buildStatisticsCard(stats),
                    const SizedBox(height: 24),
              _buildChartCard(poll, stats),
                    const SizedBox(height: 24),
              _buildDetailedResults(poll, stats),
                    const SizedBox(height: 24),
              _buildUserVoteSection(poll, pollVotes),
              const SizedBox(height: 32),
                  ],
      ),
        );
      },
    );
  }

  Widget _buildPollHeader(Poll poll) {
    final now = DateTime.now();
    final isPollOpen = !poll.isClosed && now.isBefore(poll.endDate);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPollOpen ? Icons.access_time : Icons.check_circle,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPollOpen ? 'En cours' : 'Terminé',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.analytics,
                color: Colors.white.withValues(alpha: 0.8),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            poll.question,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Du ${_formatDateTime(poll.startDate)} au ${_formatDateTime(poll.endDate)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(VoteStatistics stats) {
            return Container(
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
                  Row(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                'Statistiques générales',
                        style: GoogleFonts.poppins(
                  fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total des votes',
                  '${stats.totalVotes}',
                  Icons.how_to_vote,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Taux de participation',
                  '${((stats.totalVotes / 100) * 100).toStringAsFixed(1)}%',
                  Icons.people,
                  Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (stats.winningOptionIndex != null) ...[
            const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber[700],
                    size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                          'Option gagnante',
                                  style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                Text(
                          '${stats.percentagesPerOption[stats.winningOptionIndex!]?.toStringAsFixed(1)}% des votes',
                                  style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.amber[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                              ],
                            ),
                          ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
                          Text(
            value,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(Poll poll, VoteStatistics stats) {
    return Container(
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
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Répartition des votes',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                            ),
                          ),
                        ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(poll, stats),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                );
              },
                      ),
                    ),
                  ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Poll poll, VoteStatistics stats) {
    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    return poll.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final percentage = stats.percentagesPerOption[index] ?? 0.0;
      final votes = stats.votesPerOption[index] ?? 0;
      final isWinner = stats.winningOptionIndex == index;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: percentage * _chartAnimation.value,
        title: votes > 0 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isWinner ? 60 : 50,
        titleStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        badgeWidget: isWinner
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 16,
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }

  Widget _buildDetailedResults(Poll poll, VoteStatistics stats) {
    return Container(
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
          Row(
            children: [
              Icon(
                Icons.list_alt,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Détail des résultats',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
                  ...poll.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
            final votes = stats.votesPerOption[index] ?? 0;
                    final percentage = stats.percentagesPerOption[index] ?? 0.0;
                    final isWinner = stats.winningOptionIndex == index;
            final isMyVote = _isMyVote(index);

            return _buildResultBar(
              option: option,
              votes: votes,
              percentage: percentage,
              isWinner: isWinner,
              isMyVote: isMyVote,
              index: index,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultBar({
    required String option,
    required int votes,
    required double percentage,
    required bool isWinner,
    required bool isMyVote,
    required int index,
  }) {
    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
      padding: isWinner ? const EdgeInsets.all(8) : EdgeInsets.zero,
      decoration: isWinner
          ? BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[200]!),
            )
          : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
              if (isWinner)
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber[700],
                  size: 20,
                ),
              if (isMyVote)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
              const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Text(
                '${votes} vote${votes > 1 ? 's' : ''}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                  fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Stack(
                                children: [
                                  Container(
                height: 8,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: 8,
                width: (MediaQuery.of(context).size.width - 72) * (percentage / 100),
                                    decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(4),
                                    ),
                                        ),
                                      ],
                                    ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors[index % colors.length],
              ),
            ),
          ),
                            ],
                          ),
                        );
  }

  Widget _buildUserVoteSection(Poll poll, List<Vote> pollVotes) {
    final myVote = pollVotes.where((v) => v.userId == widget.userId).firstOrNull;
    
    if (myVote == null) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange[700],
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Vous n\'avez pas encore voté',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Participez au sondage pour voir votre vote ici',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.orange[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final selectedOption = poll.options[myVote.optionIndex];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
          Text(
                'Votre vote',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.how_to_vote,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedOption,
            style: GoogleFonts.poppins(
              fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Text(
                  _formatDateTime(myVote.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
              color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isMyVote(int optionIndex) {
    final votes = ref.watch(voteProvider);
    final myVote = votes.where((v) => 
      v.pollId == widget.pollId && v.userId == widget.userId
    ).firstOrNull;
    
    return myVote?.optionIndex == optionIndex;
  }

  Future<Poll?> _loadPoll() async {
    if (widget.pollId.isEmpty) return null;
    
    try {
      final result = await ref.read(pollRepositoryProvider).getPollById(widget.pollId);
      return result.fold(
        (failure) {
          // Log l'erreur pour le débogage
          AppLogger.e('Erreur lors du chargement du sondage ${widget.pollId}: ${failure.message}');
          return null;
        },
        (poll) => poll,
      );
    } catch (e, stack) {
      // Log l'exception pour le débogage
      AppLogger.e('Exception lors du chargement du sondage ${widget.pollId}: $e', e, stack);
      return null;
    }
  }

  void _shareResults() {
    // TODO: Implémenter le partage des résultats
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage à venir'),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  }
