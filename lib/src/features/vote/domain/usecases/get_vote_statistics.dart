import '../entities/vote.dart';

class VoteStatistics {
  final int totalVotes;
  final Map<int, int> votesPerOption;
  final Map<int, double> percentagesPerOption;
  final int? winningOptionIndex;

  const VoteStatistics({
    required this.totalVotes,
    required this.votesPerOption,
    required this.percentagesPerOption,
    this.winningOptionIndex,
  });
}

class GetVoteStatistics {
  Future<VoteStatistics> call(List<Vote> votes, int numberOfOptions) async {
    final votesPerOption = <int, int>{};
    
    // Initialiser le compteur pour chaque option
    for (int i = 0; i < numberOfOptions; i++) {
      votesPerOption[i] = 0;
    }
    
    // Compter les votes pour chaque option
    for (final vote in votes) {
      votesPerOption[vote.optionIndex] = (votesPerOption[vote.optionIndex] ?? 0) + 1;
    }
    
    final totalVotes = votes.length;
    final percentagesPerOption = <int, double>{};
    
    // Calculer les pourcentages
    for (int i = 0; i < numberOfOptions; i++) {
      final votesForOption = votesPerOption[i] ?? 0;
      percentagesPerOption[i] = totalVotes > 0 ? (votesForOption / totalVotes) * 100 : 0.0;
    }
    
    // Déterminer l'option gagnante
    int? winningOptionIndex;
    double maxPercentage = 0.0;
    for (int i = 0; i < numberOfOptions; i++) {
      final percentage = percentagesPerOption[i] ?? 0.0;
      if (percentage > maxPercentage) {
        maxPercentage = percentage;
        winningOptionIndex = i;
      }
    }
    
    // En cas d'égalité, pas de gagnant
    if (totalVotes > 0) {
      final winners = percentagesPerOption.entries
          .where((entry) => entry.value == maxPercentage)
          .map((entry) => entry.key)
          .toList();
      if (winners.length > 1) {
        winningOptionIndex = null; // Égalité
      }
    }
    
    return VoteStatistics(
      totalVotes: totalVotes,
      votesPerOption: votesPerOption,
      percentagesPerOption: percentagesPerOption,
      winningOptionIndex: winningOptionIndex,
    );
  }
} 