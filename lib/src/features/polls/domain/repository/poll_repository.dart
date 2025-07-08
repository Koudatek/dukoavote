import '../entities/poll.dart';

abstract class PollRepository {
  List<Poll> getAllPolls();
  Poll? getPollById(String id);
  Future<void> addPoll(Poll poll);
  Future<void> closePoll(String id, {String? closedReason});
} 