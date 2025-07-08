import '../../domain/entities/poll.dart';

class PollModel extends Poll {
  const PollModel({
    super.id,
    required super.question,
    required super.options,
    required super.startDate,
    required super.endDate,
    required super.isClosed,
    super.createdBy,
    super.closedReason,
  });

  factory PollModel.fromMap(Map<String, dynamic> map) {
    try {
      return PollModel(
        id: map['id']?.toString(),
        question: map['question'] as String? ?? '',
        options: List<String>.from(map['options'] as List? ?? []),
        startDate: DateTime.parse(map['start_date'] as String? ?? DateTime.now().toIso8601String()),
        endDate: DateTime.parse(map['end_date'] as String? ?? DateTime.now().add(const Duration(days: 1)).toIso8601String()),
        isClosed: map['is_closed'] as bool? ?? false,
        createdBy: map['created_by'] as String?,
        closedReason: map['closed_reason'] as String?,
      );
    } catch (e) {
      throw FormatException('Erreur lors du parsing du sondage: $e. Données: $map');
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'question': question,
      'options': options,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_closed': isClosed,
    };
    
    // N'inclure l'ID que s'il existe (pour les mises à jour)
    if (id != null) {
      map['id'] = id;
    }
    
    // N'inclure created_by que s'il existe
    if (createdBy != null) {
      map['created_by'] = createdBy;
    }
    
    if (closedReason != null) {
      map['closed_reason'] = closedReason;
    }
    
    return map;
  }

  factory PollModel.fromEntity(Poll poll) {
    return PollModel(
      id: poll.id,
      question: poll.question,
      options: poll.options,
      startDate: poll.startDate,
      endDate: poll.endDate,
      isClosed: poll.isClosed,
      createdBy: poll.createdBy,
      closedReason: poll.closedReason,
    );
  }

  PollModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    DateTime? startDate,
    DateTime? endDate,
    bool? isClosed,
    String? createdBy,
    String? closedReason,
  }) {
    return PollModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isClosed: isClosed ?? this.isClosed,
      createdBy: createdBy ?? this.createdBy,
      closedReason: closedReason ?? this.closedReason,
    );
  }
} 