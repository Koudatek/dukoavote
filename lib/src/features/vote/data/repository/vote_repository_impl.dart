import '../../domain/entities/vote.dart';
import '../../domain/repository/vote_repository.dart';
import '../datasource/vote_remote_datasource.dart';
import '../models/vote_model.dart';

class VoteRepositoryImpl implements VoteRepository {
  final VoteRemoteDatasource remoteDatasource;

  VoteRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> submitVote(Vote vote) async {
    await remoteDatasource.submitVote(VoteModel(
      id: vote.id,
      pollId: vote.pollId,
      userId: vote.userId,
      optionIndex: vote.optionIndex,
      createdAt: vote.createdAt,
    ));
  }

  @override
  Future<List<Vote>> getVotesForPoll(String pollId) async {
    return await remoteDatasource.getVotesForPoll(pollId);
  }
} 