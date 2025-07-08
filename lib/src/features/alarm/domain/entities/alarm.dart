import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final String id;
  final String pollId;
  final DateTime triggerTime;
  final bool isActive;

  const Alarm({
    required this.id,
    required this.pollId,
    required this.triggerTime,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, pollId, triggerTime, isActive];

  Alarm copyWith({
    String? id,
    String? pollId,
    DateTime? triggerTime,
    bool? isActive,
  }) {
    return Alarm(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      triggerTime: triggerTime ?? this.triggerTime,
      isActive: isActive ?? this.isActive,
    );
  }
} 