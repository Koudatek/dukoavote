import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

class RejectPollRequest {
  final PollRequestRepository repository;

  const RejectPollRequest(this.repository);

  Future<Either<Failure, void>> call(String requestId, String reviewedBy, String reason) async {
    return await repository.rejectPollRequest(requestId, reviewedBy, reason);
  }
} 