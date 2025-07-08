import 'package:dukoavote/src/features/polls/domain/entities/poll.dart';
import 'package:dukoavote/src/features/polls/domain/repository/poll_repository.dart';


class GetAllPolls {
  final PollRepository repository;
  GetAllPolls(this.repository);

  List<Poll> call() {
    return repository.getAllPolls();
  }
} 