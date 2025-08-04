import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';

abstract class PollRequestRepository {
  /// Soumettre une nouvelle demande de question
  Future<Either<Failure, void>> submitPollRequest(PollRequest request);
  
  /// Récupérer toutes les demandes d'un utilisateur
  Future<Either<Failure, List<PollRequest>>> getUserPollRequests(String userId);
  
  /// Récupérer toutes les demandes en attente (pour les admins)
  Future<Either<Failure, List<PollRequest>>> getPendingPollRequests();
  
  /// Approuver une demande de question
  Future<Either<Failure, void>> approvePollRequest(String requestId, String reviewedBy);
  
  /// Rejeter une demande de question
  Future<Either<Failure, void>> rejectPollRequest(String requestId, String reviewedBy, String reason);
} 