import 'package:dukoavote/src/features/features.dart';

/// Données de test pour la page de résultats
class ResultsTestData {
  /// Sondage de test avec des données complètes
  static Poll get testPoll => Poll(
    id: 'test-poll-id',
    question: 'Quelle est votre couleur préférée ?',
    options: [
      'Rouge',
      'Bleu',
      'Vert',
      'Jaune',
      'Violet',
    ],
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 1)),
    isClosed: false,
    createdBy: 'test-user-id',
  );

  /// Sondage fermé pour tester les résultats finaux
  static Poll get closedTestPoll => Poll(
    id: 'closed-test-poll-id',
    question: 'Quel est votre plat préféré ?',
    options: [
      'Pizza',
      'Sushi',
      'Burger',
      'Salade',
      'Pâtes',
    ],
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    endDate: DateTime.now().subtract(const Duration(hours: 1)),
    isClosed: true,
    createdBy: 'test-user-id',
    closedReason: 'Sondage terminé automatiquement',
  );

  /// Votes de test pour le sondage
  static List<Vote> get testVotes => [
    Vote(
      id: 'vote-1',
      pollId: 'test-poll-id',
      userId: 'user-1',
      optionIndex: 0, // Rouge
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Vote(
      id: 'vote-2',
      pollId: 'test-poll-id',
      userId: 'user-2',
      optionIndex: 1, // Bleu
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Vote(
      id: 'vote-3',
      pollId: 'test-poll-id',
      userId: 'user-3',
      optionIndex: 1, // Bleu
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Vote(
      id: 'vote-4',
      pollId: 'test-poll-id',
      userId: 'user-4',
      optionIndex: 2, // Vert
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    Vote(
      id: 'vote-5',
      pollId: 'test-poll-id',
      userId: 'user-5',
      optionIndex: 0, // Rouge
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  /// Votes pour le sondage fermé
  static List<Vote> get closedTestVotes => [
    Vote(
      id: 'closed-vote-1',
      pollId: 'closed-test-poll-id',
      userId: 'user-1',
      optionIndex: 0, // Pizza
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Vote(
      id: 'closed-vote-2',
      pollId: 'closed-test-poll-id',
      userId: 'user-2',
      optionIndex: 1, // Sushi
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Vote(
      id: 'closed-vote-3',
      pollId: 'closed-test-poll-id',
      userId: 'user-3',
      optionIndex: 1, // Sushi
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Vote(
      id: 'closed-vote-4',
      pollId: 'closed-test-poll-id',
      userId: 'user-4',
      optionIndex: 2, // Burger
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Vote(
      id: 'closed-vote-5',
      pollId: 'closed-test-poll-id',
      userId: 'user-5',
      optionIndex: 1, // Sushi
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Vote(
      id: 'closed-vote-6',
      pollId: 'closed-test-poll-id',
      userId: 'user-6',
      optionIndex: 3, // Salade
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  /// Statistiques calculées pour le sondage de test
  static Map<String, dynamic> get testStatistics => {
    'totalVotes': 5,
    'votesPerOption': {
      0: 2, // Rouge
      1: 2, // Bleu
      2: 1, // Vert
      3: 0, // Jaune
      4: 0, // Violet
    },
    'percentagesPerOption': {
      0: 40.0, // Rouge
      1: 40.0, // Bleu
      2: 20.0, // Vert
      3: 0.0,  // Jaune
      4: 0.0,  // Violet
    },
    'winningOptionIndex': 0, // Rouge (premier dans la liste)
  };

  /// Statistiques pour le sondage fermé
  static Map<String, dynamic> get closedTestStatistics => {
    'totalVotes': 6,
    'votesPerOption': {
      0: 1, // Pizza
      1: 3, // Sushi
      2: 1, // Burger
      3: 1, // Salade
      4: 0, // Pâtes
    },
    'percentagesPerOption': {
      0: 16.7, // Pizza
      1: 50.0, // Sushi
      2: 16.7, // Burger
      3: 16.7, // Salade
      4: 0.0,  // Pâtes
    },
    'winningOptionIndex': 1, // Sushi
  };
} 