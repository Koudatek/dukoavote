import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

class ApprovePollRequest {
  final PollRequestRepository repository;

  const ApprovePollRequest(this.repository);

  Future<Either<Failure, void>> call(String requestId, String reviewedBy) async {
    return await repository.approvePollRequest(requestId, reviewedBy);
  }
} 