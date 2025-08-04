import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

class GetPendingPollRequests {
  final PollRequestRepository repository;

  const GetPendingPollRequests(this.repository);

  Future<Either<Failure, List<PollRequest>>> call() async {
    return await repository.getPendingPollRequests();
  }
} 