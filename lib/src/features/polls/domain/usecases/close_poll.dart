
import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

class ClosePoll {
  final PollRepository repository;

  const ClosePoll(this.repository);

  Future<Either<Failure, void>> call(String pollId) async {
    return await repository.closePoll(pollId);
  }
} 