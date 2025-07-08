
import '../repository/poll_repository.dart';

class ClosePoll {
  final PollRepository repository;

  ClosePoll(this.repository);

  Future<void> call(String pollId) async {
    await repository.closePoll(pollId);
  }
} 