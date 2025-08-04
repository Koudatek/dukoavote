

import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

class CreatePoll {
  final PollRepository repository;
  
  const CreatePoll(this.repository);

  Future<Either<Failure, void>> call(Poll poll) async {
    return await repository.addPoll(poll);
  }
} 