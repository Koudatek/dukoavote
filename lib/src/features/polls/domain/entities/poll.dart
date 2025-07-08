import 'package:equatable/equatable.dart';

class Poll extends Equatable {
  final String? id;
  final String question;
  final List<String> options;
  final DateTime startDate;
  final DateTime endDate;
  final bool isClosed;
  final String? createdBy;
  final String? closedReason; // 'manual', 'timeout', ou null

  const Poll({
    this.id,
    required this.question,
    required this.options,
    required this.startDate,
    required this.endDate,
    required this.isClosed,
    this.createdBy,
    this.closedReason,
  });

  @override
  List<Object?> get props => [id, question, options, startDate, endDate, isClosed, createdBy, closedReason];
} 