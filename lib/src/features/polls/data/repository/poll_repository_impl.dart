import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

class PollRepositoryImpl implements PollRepository {
  final PollLocalDataSource dataSource;
  
  const PollRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Poll>>> getAllPolls() async {
    try {
      final polls = dataSource.getAllPolls();
      return Right(polls);
    } catch (e) {
      return Left(CacheFailure('Erreur lors de la récupération des questions: $e'));
    }
  }

  @override
  Future<Either<Failure, Poll?>> getPollById(String id) async {
    try {
      final poll = dataSource.getPollById(id);
      return Right(poll);
    } catch (e) {
      return Left(CacheFailure('Erreur lors de la récupération de la question: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPoll(Poll poll) async {
    try {
      final model = poll is PollModel ? poll : PollModel.fromEntity(poll);
      await dataSource.addPoll(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erreur lors de l\'ajout de la question: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> closePoll(String id, {String? closedReason}) async {
    try {
      await dataSource.closePoll(id, closedReason: closedReason);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erreur lors de la fermeture de la question: $e'));
    }
  }
} 