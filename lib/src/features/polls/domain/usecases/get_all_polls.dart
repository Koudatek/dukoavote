import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

class GetAllPolls {
  final PollRepository repository;
  
  const GetAllPolls(this.repository);

  Future<Either<Failure, List<Poll>>> call() async {
    return await repository.getAllPolls();
  }
} 