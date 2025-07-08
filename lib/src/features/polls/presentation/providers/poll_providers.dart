import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_providers.dart';
import '../../data/datasource/poll_remote_repository.dart';
import '../../domain/entities/poll.dart';
import '../../domain/repository/poll_repository.dart';
import '../../domain/usecases/create_poll.dart';



final pollRemoteRepositoryProvider = Provider<PollRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PollRemoteRepository(client);
});

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  // return PollRepositoryImpl(PollLocalDataSource());
  return ref.watch(pollRemoteRepositoryProvider);
});

final pollsProvider = FutureProvider<List<Poll>>((ref) async {
  final repo = ref.watch(pollRepositoryProvider);
  
  if (repo is PollRemoteRepository) {
    return repo.getAllPollsAsync();
  } else {
  return repo.getAllPolls();
  }
});

final createPollProvider = Provider<CreatePoll>((ref) {
  final repo = ref.watch(pollRepositoryProvider);
  return CreatePoll(repo);
});

Future<void> createPollAndRefresh(WidgetRef ref, Poll poll) async {
  final createPoll = ref.read(createPollProvider);
  await createPoll(poll);
  ref.invalidate(pollsProvider);
}

// --- Provider complet pour la création de sondage ---
enum CreatePollStatus { initial, loading, success, error }

class CreatePollState {
  final CreatePollStatus status;
  final String? error;

  const CreatePollState({this.status = CreatePollStatus.initial, this.error});

  CreatePollState copyWith({CreatePollStatus? status, String? error}) =>
      CreatePollState(
        status: status ?? this.status,
        error: error,
      );
}

class CreatePollNotifier extends StateNotifier<CreatePollState> {
  final CreatePoll createPoll;

  CreatePollNotifier(this.createPoll) : super(const CreatePollState());

  Future<void> submit(Poll poll) async {
    state = state.copyWith(status: CreatePollStatus.loading, error: null);
    try {
      await createPoll(poll);
      state = state.copyWith(status: CreatePollStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: CreatePollStatus.error,
        error: e.toString(),
      );
    }
  }

  void reset() => state = const CreatePollState();
}

final createPollNotifierProvider =
    StateNotifierProvider<CreatePollNotifier, CreatePollState>((ref) {
  final usecase = ref.watch(createPollProvider);
  return CreatePollNotifier(usecase);
}); 

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
      final polls = await _ref.read(pollsProvider.future);
      final now = DateTime.now();
      bool hasChanges = false;

      for (final poll in polls) {
        if (!poll.isClosed && now.isAfter(poll.endDate)) {
          // Fermer le sondage automatiquement
          final repo = _ref.read(pollRepositoryProvider);
          await repo.closePoll(poll.id!);
          hasChanges = true;
        }
      }

      // Rafraîchir la liste si des changements ont été effectués
      if (hasChanges) {
        _ref.invalidate(pollsProvider);
      }
    } catch (e) {
      // Log l'erreur mais ne pas faire planter l'app
      print('Erreur lors de la vérification des sondages expirés: $e');
    }
  }
} 