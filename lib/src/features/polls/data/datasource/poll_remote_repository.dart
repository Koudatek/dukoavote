import 'package:dukoavote/src/features/polls/domain/repository/poll_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/poll.dart';
import '../models/poll_model.dart';
import 'package:dukoavote/src/core/utils/app_logger.dart';

class PollRemoteRepository implements PollRepository {
  final SupabaseClient client;

  PollRemoteRepository(this.client);

  @override
  Future<void> addPoll(Poll poll) async {
    final model = poll is PollModel ? poll : PollModel.fromEntity(poll);
    final dataToInsert = model.toMap();
    
    try {
      await client.from('polls').insert(dataToInsert);
    } catch (e, stack) {
      AppLogger.e("Erreur lors de l'insertion du sondage : $e", e, stack);
      throw Exception("Erreur lors de la création du sondage. Veuillez réessayer.");
    }
  }

  @override
  Future<void> closePoll(String id, {String? closedReason}) async {
    try {
      final Map<String, dynamic> updateData = {'is_closed': true};
      if (closedReason != null) {
        updateData['closed_reason'] = closedReason;
      }
      await client.from('polls').update(updateData).eq('id', id);
    } catch (e, stack) {
      AppLogger.e("Erreur lors de la fermeture du sondage : $e", e, stack);
      throw Exception("Erreur lors de la fermeture du sondage. Veuillez réessayer.");
    }
  }

  @override
  List<Poll> getAllPolls() {
    throw UnimplementedError('Use getAllPollsAsync for remote');
  }

  @override
  Poll? getPollById(String id) {
    throw UnimplementedError('Use getPollByIdAsync for remote');
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