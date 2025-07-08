import 'package:equatable/equatable.dart';

class Vote extends Equatable {
  final String id;
  final String pollId;
  final String userId;
  final int optionIndex;
  final DateTime createdAt;

  const Vote({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.optionIndex,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, pollId, userId, optionIndex, createdAt];
} 