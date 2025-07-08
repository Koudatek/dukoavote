import '../entities/vote.dart';

abstract class VoteRepository {
  Future<void> submitVote(Vote vote);
  Future<List<Vote>> getVotesForPoll(String pollId);
} 