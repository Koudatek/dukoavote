import '../entities/vote.dart';
import '../repository/vote_repository.dart';

class GetVotes {
  final VoteRepository repository;

  GetVotes(this.repository);

  Future<List<Vote>> call(String pollId) => repository.getVotesForPoll(pollId);
} 