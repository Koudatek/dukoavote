import '../models/poll_model.dart';

class PollLocalDataSource {
  final List<PollModel> _polls = [];

  List<PollModel> getAllPolls() => List.unmodifiable(_polls);

  PollModel? getPollById(String id) {
    try {
      return _polls.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addPoll(PollModel poll) async => _polls.add(poll);

  Future<void> closePoll(String id, {String? closedReason}) async {
    final poll = getPollById(id);
    if (poll != null) {
      final idx = _polls.indexWhere((p) => p.id == id);
      _polls[idx] = poll.copyWith(isClosed: true, closedReason: closedReason);
    }
  }
} 