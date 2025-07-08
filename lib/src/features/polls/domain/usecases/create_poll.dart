

import 'package:dukoavote/src/features/polls/domain/entities/poll.dart';
import 'package:dukoavote/src/features/polls/domain/repository/poll_repository.dart';

class CreatePoll {
  final PollRepository repository;
  CreatePoll(this.repository);

  Future<void> call(Poll poll) async {
    await repository.addPoll(poll);
  }
} 