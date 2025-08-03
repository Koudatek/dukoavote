import 'package:dukoavote/src/src.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final voteRemoteDatasourceProvider = Provider<VoteRemoteDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return VoteRemoteDatasourceImpl(client);
});

final voteRepositoryProvider = Provider((ref) {
  final datasource = ref.watch(voteRemoteDatasourceProvider);
  return VoteRepositoryImpl(datasource);
});

final submitVoteProvider = Provider((ref) {
  final repo = ref.watch(voteRepositoryProvider);
  return SubmitVote(repo);
});

final getVotesProvider = Provider((ref) {
  final repo = ref.watch(voteRepositoryProvider);
  return GetVotes(repo);
});

final voteProvider = StateNotifierProvider<VoteNotifier, List<Vote>>((ref) {
  final submitVote = ref.watch(submitVoteProvider);
  final getVotes = ref.watch(getVotesProvider);
  return VoteNotifier(submitVote: submitVote, getVotes: getVotes);
});

class VoteNotifier extends StateNotifier<List<Vote>> {
  final SubmitVote submitVote;
  final GetVotes getVotes;

  VoteNotifier({required this.submitVote, required this.getVotes}) : super([]);

  Future<void> loadVotes(String pollId) async {
    state = await getVotes(pollId);
  }

  Future<void> vote(Vote vote) async {
    try {
    await submitVote(vote);
      // Recharger les votes après avoir voté
      await loadVotes(vote.pollId);
    } catch (e) {
      // Gérer l'erreur ici si nécessaire
      rethrow;
    }
  }
} 