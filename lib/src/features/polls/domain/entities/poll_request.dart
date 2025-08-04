class PollRequest {
  final String? id;
  final String userId;
  final String question;
  final List<String> options;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  const PollRequest({
    this.id,
    required this.userId,
    required this.question,
    required this.options,
    required this.status,
    required this.requestedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  PollRequest copyWith({
    String? id,
    String? userId,
    String? question,
    List<String>? options,
    String? status,
    DateTime? requestedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
  }) {
    return PollRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      question: question ?? this.question,
      options: options ?? this.options,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'question': question,
      'options': options,
      'status': status,
      'requested_at': requestedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
      'rejection_reason': rejectionReason,
    };
  }

  factory PollRequest.fromJson(Map<String, dynamic> json) {
    return PollRequest(
      id: json['id'],
      userId: json['user_id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      status: json['status'],
      requestedAt: DateTime.parse(json['requested_at']),
      reviewedAt: json['reviewed_at'] != null 
          ? DateTime.parse(json['reviewed_at']) 
          : null,
      reviewedBy: json['reviewed_by'],
      rejectionReason: json['rejection_reason'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PollRequest &&
        other.id == id &&
        other.userId == userId &&
        other.question == question &&
        other.options == options &&
        other.status == status &&
        other.requestedAt == requestedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      question,
      options,
      status,
      requestedAt,
    );
  }

  @override
  String toString() {
    return 'PollRequest(id: $id, userId: $userId, question: $question, status: $status)';
  }
} 