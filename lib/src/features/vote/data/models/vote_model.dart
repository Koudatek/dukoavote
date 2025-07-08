import '../../domain/entities/vote.dart';

class VoteModel extends Vote {
  const VoteModel({
    required super.id,
    required super.pollId,
    required super.userId,
    required super.optionIndex,
    required super.createdAt,
  });

  factory VoteModel.fromMap(Map<String, dynamic> map) {
    try {
      return VoteModel(
        id: map['id']?.toString() ?? '',
        pollId: map['poll_id']?.toString() ?? '',
        userId: map['user_id']?.toString() ?? '',
        optionIndex: map['option_index'] as int? ?? 0,
        createdAt: DateTime.parse(map['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      throw FormatException('Erreur lors du parsing du vote: $e. Données: $map');
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'poll_id': pollId,
        'user_id': userId,
        'option_index': optionIndex,
        'created_at': createdAt.toIso8601String(),
      };
} 