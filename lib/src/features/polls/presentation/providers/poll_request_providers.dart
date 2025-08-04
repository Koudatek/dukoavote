import 'package:dukoavote/src/src.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

// Repository provider
final pollRequestRepositoryProvider = Provider<PollRequestRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PollRequestRepositoryImpl(supabase);
});

// Use case providers
final submitPollRequestProvider = Provider<SubmitPollRequest>((ref) {
  final repository = ref.watch(pollRequestRepositoryProvider);
  return SubmitPollRequest(repository);
});

final getUserPollRequestsProvider = Provider<GetUserPollRequests>((ref) {
  final repository = ref.watch(pollRequestRepositoryProvider);
  return GetUserPollRequests(repository);
});

final getPendingPollRequestsProvider = Provider<GetPendingPollRequests>((ref) {
  final repository = ref.watch(pollRequestRepositoryProvider);
  return GetPendingPollRequests(repository);
});

final approvePollRequestProvider = Provider<ApprovePollRequest>((ref) {
  final repository = ref.watch(pollRequestRepositoryProvider);
  return ApprovePollRequest(repository);
});

final rejectPollRequestProvider = Provider<RejectPollRequest>((ref) {
  final repository = ref.watch(pollRequestRepositoryProvider);
  return RejectPollRequest(repository);
});

// State providers
final userPollRequestsProvider = FutureProvider.family<Either<Failure, List<PollRequest>>, String>(
  (ref, userId) async {
    final useCase = ref.watch(getUserPollRequestsProvider);
    return useCase(userId);
  },
);

final pendingPollRequestsProvider = FutureProvider<Either<Failure, List<PollRequest>>>((ref) async {
  final useCase = ref.watch(getPendingPollRequestsProvider);
  return useCase();
});

// Provider pour soumettre une demande
final submitPollRequestNotifierProvider = StateNotifierProvider<SubmitPollRequestNotifier, AsyncValue<Either<Failure, void>>>((ref) {
  final submitPollRequest = ref.watch(submitPollRequestProvider);
  return SubmitPollRequestNotifier(submitPollRequest);
});

class SubmitPollRequestNotifier extends StateNotifier<AsyncValue<Either<Failure, void>>> {
  final SubmitPollRequest _submitPollRequest;

  SubmitPollRequestNotifier(this._submitPollRequest) : super(const AsyncValue.data(Right(null)));

  Future<void> submitRequest(String userId, String question, List<String> options) async {
    state = const AsyncValue.loading();
    
    final result = await _submitPollRequest(userId, question, options);
    state = AsyncValue.data(result);
  }
} 