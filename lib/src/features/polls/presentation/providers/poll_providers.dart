import 'dart:async';
import 'package:dukoavote/src/src.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

// Repository providers
final pollRemoteRepositoryProvider = Provider<PollRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PollRemoteRepository(client);
});

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  return ref.watch(pollRemoteRepositoryProvider);
});

// Use case providers
final getAllPollsProvider = Provider<GetAllPolls>((ref) {
  final repository = ref.watch(pollRepositoryProvider);
  return GetAllPolls(repository);
});

final createPollProvider = Provider<CreatePoll>((ref) {
  final repository = ref.watch(pollRepositoryProvider);
  return CreatePoll(repository);
});

final closePollProvider = Provider<ClosePoll>((ref) {
  final repository = ref.watch(pollRepositoryProvider);
  return ClosePoll(repository);
});

// State providers
final pollsProvider = FutureProvider<Either<Failure, List<Poll>>>((ref) async {
  final useCase = ref.watch(getAllPollsProvider);
  return useCase();
});

// Provider pour soumettre un sondage
final createPollNotifierProvider = StateNotifierProvider<CreatePollNotifier, AsyncValue<Either<Failure, void>>>((ref) {
  final createPoll = ref.watch(createPollProvider);
  return CreatePollNotifier(createPoll);
});

class CreatePollNotifier extends StateNotifier<AsyncValue<Either<Failure, void>>> {
  final CreatePoll _createPoll;

  CreatePollNotifier(this._createPoll) : super(const AsyncValue.data(Right(null)));

  Future<void> submit(Poll poll) async {
    state = const AsyncValue.loading();
    
    final result = await _createPoll(poll);
    state = AsyncValue.data(result);
  }
}

// Provider pour rafraîchir automatiquement les sondages
final autoRefreshPollsProvider = Provider<AutoRefreshPolls>((ref) {
  return AutoRefreshPolls(ref);
});

class AutoRefreshPolls {
  final Ref _ref;
  Timer? _timer;

  AutoRefreshPolls(this._ref);

  void startAutoRefresh() {
    // Vérifier toutes les minutes si des sondages doivent être fermés
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAndCloseExpiredPolls();
    });
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkAndCloseExpiredPolls() async {
    try {
      final pollsResult = await _ref.read(pollsProvider.future);
      
      pollsResult.fold(
        (failure) {
          // Log l'erreur mais ne pas faire planter l'app
          print('Erreur lors de la récupération des sondages: ${failure.message}');
        },
        (polls) async {
          final now = DateTime.now();
          bool hasChanges = false;

          for (final poll in polls) {
            if (!poll.isClosed && now.isAfter(poll.endDate)) {
              // Fermer le sondage automatiquement
              final closePoll = _ref.read(closePollProvider);
              final result = await closePoll(poll.id!);
              
              result.fold(
                (failure) => print('Erreur lors de la fermeture du sondage: ${failure.message}'),
                (_) => hasChanges = true,
              );
            }
          }

          // Rafraîchir la liste si des changements ont été effectués
          if (hasChanges) {
            _ref.invalidate(pollsProvider);
          }
        },
      );
    } catch (e) {
      // Log l'erreur mais ne pas faire planter l'app
      print('Erreur lors de la vérification des sondages expirés: $e');
    }
  }
} 