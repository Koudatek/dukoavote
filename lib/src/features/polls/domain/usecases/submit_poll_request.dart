
import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

class SubmitPollRequest {
  final PollRequestRepository repository;

  const SubmitPollRequest(this.repository);

  Future<Either<Failure, void>> call(String userId, String question, List<String> options) async {
    final request = PollRequest(
      userId: userId,
      question: question,
      options: options,
      status: 'pending',
      requestedAt: DateTime.now(),
    );

    return await repository.submitPollRequest(request);
  }
} 