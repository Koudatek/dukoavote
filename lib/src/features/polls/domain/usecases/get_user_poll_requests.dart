import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

class GetUserPollRequests {
  final PollRequestRepository repository;

  const GetUserPollRequests(this.repository);

  Future<Either<Failure, List<PollRequest>>> call(String userId) async {
    return await repository.getUserPollRequests(userId);
  }
} 