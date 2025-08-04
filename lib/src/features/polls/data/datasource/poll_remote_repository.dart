import 'package:dukoavote/src/src.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PollRemoteRepository implements PollRepository {
  final SupabaseClient client;

  const PollRemoteRepository(this.client);

  @override
  Future<Either<Failure, void>> addPoll(Poll poll) async {
    final model = poll is PollModel ? poll : PollModel.fromEntity(poll);
    final dataToInsert = model.toMap();

    // Récupérer l'ID de l'utilisateur connecté
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      return Left(AuthFailure("Vous devez être connecté pour créer un sondage."));
    }

    // Ajouter l'ID de l'utilisateur connecté
    dataToInsert['created_by'] = currentUser.id;

    try {
      await client.from('polls').insert(dataToInsert);
      return const Right(null);
    } catch (e, stack) {
      AppLogger.e("Erreur lors de l'insertion du sondage : $e", e, stack);
      return Left(ServerFailure("Erreur lors de la création du sondage. Veuillez réessayer."));
    }
  }

  @override
  Future<Either<Failure, void>> closePoll(String id, {String? closedReason}) async {
    try {
      final Map<String, dynamic> updateData = {'is_closed': true};
      if (closedReason != null) {
        updateData['closed_reason'] = closedReason;
      }
      await client.from('polls').update(updateData).eq('id', id);
      return const Right(null);
    } catch (e, stack) {
      AppLogger.e("Erreur lors de la fermeture du sondage : $e", e, stack);
      return Left(ServerFailure("Erreur lors de la fermeture du sondage. Veuillez réessayer."));
    }
  }

  @override
  Future<Either<Failure, List<Poll>>> getAllPolls() async {
    try {
      final data = await client.from('polls').select().order('id', ascending: false);
      final polls = (data as List).map((e) => PollModel.fromMap(e)).toList();
      return Right(polls);
    } catch (e, stack) {
      AppLogger.e("Erreur lors de la récupération des sondages : $e", e, stack);
      return Left(ServerFailure("Erreur lors du chargement des sondages."));
    }
  }

  @override
  Future<Either<Failure, Poll?>> getPollById(String id) async {
    try {
      final data = await client.from('polls').select().eq('id', id).maybeSingle();
      if (data == null) {
        return const Right(null);
      }
      return Right(PollModel.fromMap(data));
    } catch (e, stack) {
      AppLogger.e("Erreur lors de la récupération du sondage : $e", e, stack);
      return Left(ServerFailure("Erreur lors de la récupération du sondage."));
    }
  }

  Future<List<Poll>> getAllPollsAsync() async {
    try {
      final data = await client.from('polls').select().order('id', ascending: false);
      
      final polls = (data as List).map((e) {
        try {
          return PollModel.fromMap(e);
        } catch (parseError, parseStack) {
          AppLogger.e("Erreur lors du parsing d'un sondage: $parseError", parseError, parseStack);
          rethrow;
        }
      }).toList();
      
      return polls;
    } catch (e, stack) {
      AppLogger.e("Erreur lors de la récupération des sondages : $e", e, stack);
      throw Exception("Erreur lors du chargement des sondages.");
    }
  }

  Future<Poll?> getPollByIdAsync(String id) async {
    try {
      final data = await client.from('polls').select().eq('id', id).single();
      return PollModel.fromMap(data);
    } catch (e, stack) {
      AppLogger.e("Erreur lors de la récupération du sondage : $e", e, stack);
      throw Exception("Erreur lors de la récupération du sondage.");
    }
  }
}