import '../../domain/entities/poll.dart';
import '../../domain/repository/poll_repository.dart';
import '../models/poll_model.dart';
import '../datasource/poll_local_datasource.dart';

class PollRepositoryImpl implements PollRepository {
  final PollLocalDataSource dataSource;
  PollRepositoryImpl(this.dataSource);

  @override
  List<Poll> getAllPolls() => dataSource.getAllPolls();

  @override
  Poll? getPollById(String id) => dataSource.getPollById(id);

  @override
  Future<void> addPoll(Poll poll) async {
    final model = poll is PollModel ? poll : PollModel.fromEntity(poll);
    await dataSource.addPoll(model);
  }

  @override
  Future<void> closePoll(String id, {String? closedReason}) async {
    await dataSource.closePoll(id, closedReason: closedReason);
  }
} 