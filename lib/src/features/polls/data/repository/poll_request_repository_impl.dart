import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PollRequestRepositoryImpl implements PollRequestRepository {
  final SupabaseClient _supabase;

  const PollRequestRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, void>> submitPollRequest(PollRequest request) async {
    try {
      await _supabase
          .from('poll_requests')
          .insert(request.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la soumission de la demande: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PollRequest>>> getUserPollRequests(String userId) async {
    try {
      final response = await _supabase
          .from('poll_requests')
          .select()
          .eq('user_id', userId)
          .order('requested_at', ascending: false);

      final requests = (response as List)
          .map((json) => PollRequest.fromJson(json))
          .toList();
      
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la récupération des demandes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PollRequest>>> getPendingPollRequests() async {
    try {
      final response = await _supabase
          .from('poll_requests')
          .select()
          .eq('status', 'pending')
          .order('requested_at', ascending: true);

      final requests = (response as List)
          .map((json) => PollRequest.fromJson(json))
          .toList();
      
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la récupération des demandes en attente: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> approvePollRequest(String requestId, String reviewedBy) async {
    try {
      await _supabase
          .from('poll_requests')
          .update({
            'status': 'approved',
            'reviewed_at': DateTime.now().toIso8601String(),
            'reviewed_by': reviewedBy,
          })
          .eq('id', requestId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de l\'approbation de la demande: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectPollRequest(String requestId, String reviewedBy, String reason) async {
    try {
      await _supabase
          .from('poll_requests')
          .update({
            'status': 'rejected',
            'reviewed_at': DateTime.now().toIso8601String(),
            'reviewed_by': reviewedBy,
            'rejection_reason': reason,
          })
          .eq('id', requestId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors du rejet de la demande: $e'));
    }
  }
} 