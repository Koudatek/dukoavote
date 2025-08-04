import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

abstract class PollRepository {
  /// Récupérer toutes les questions
  Future<Either<Failure, List<Poll>>> getAllPolls();
  
  /// Récupérer une question par son ID
  Future<Either<Failure, Poll?>> getPollById(String id);
  
  /// Ajouter une nouvelle question
  Future<Either<Failure, void>> addPoll(Poll poll);
  
  /// Fermer une question
  Future<Either<Failure, void>> closePoll(String id, {String? closedReason});
} 