import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vote_model.dart';
import 'package:dukoavote/src/core/utils/app_logger.dart';

abstract class VoteRemoteDatasource {
  Future<void> submitVote(VoteModel vote);
  Future<List<VoteModel>> getVotesForPoll(String pollId);
}

class VoteRemoteDatasourceImpl implements VoteRemoteDatasource {
  final SupabaseClient client;

  VoteRemoteDatasourceImpl(this.client);

  @override
  Future<void> submitVote(VoteModel vote) async {
    try {
    final data = vote.toMap();
    data.remove('id');
      
      // Utiliser l'ID de l'utilisateur authentifié
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception("Utilisateur non authentifié");
      }
      data['user_id'] = currentUserId;
      
      // Essayer d'abord un insert simple
      try {
        await client.from('votes').insert(data);
      } catch (e) {
        // Si l'insert échoue à cause d'un doublon, mettre à jour
        if (e.toString().contains('duplicate key')) {
    await client
        .from('votes')
              .update({
                'option_index': data['option_index'],
                'created_at': data['created_at'],
              })
              .eq('poll_id', data['poll_id'])
              .eq('user_id', data['user_id']);
        } else {
          rethrow;
        }
      }
    } catch (e, stack) {
      AppLogger.e("Erreur lors de la soumission du vote: $e", e, stack);
      throw Exception("Erreur lors de la soumission du vote. Veuillez réessayer.");
    }
  }

  @override
  Future<List<VoteModel>> getVotesForPoll(String pollId) async {
    try {
    final data = await client
        .from('votes')
        .select()
        .eq('poll_id', pollId);
      
      final votes = (data as List).map((e) {
        try {
          return VoteModel.fromMap(e as Map<String, dynamic>);
        } catch (parseError, parseStack) {
          AppLogger.e("Erreur lors du parsing d'un vote: $parseError", parseError, parseStack);
          rethrow;
        }
      }).toList();
      
      return votes;
    } catch (e, stack) {
      AppLogger.e("Erreur lors de la récupération des votes: $e", e, stack);
      throw Exception("Erreur lors du chargement des votes.");
    }
  }
} 