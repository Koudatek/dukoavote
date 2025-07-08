import '../entities/vote.dart';
import '../repository/vote_repository.dart';

class SubmitVote {
  final VoteRepository repository;

  SubmitVote(this.repository);

  Future<void> call(Vote vote) => repository.submitVote(vote);
} 