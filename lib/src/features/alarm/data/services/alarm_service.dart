import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dukoavote/src/core/utils/app_logger.dart';
import '../../../polls/domain/repository/poll_repository.dart';
import '../../../polls/domain/entities/poll.dart';
import '../../domain/entities/alarm.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Map<String, Timer> _activeTimers = {};
  final Map<String, Alarm> _activeAlarms = {};
  PollRepository? _repository;
  bool _isInitialized = false;

  /// Initialise le service d'alarme
  Future<void> initialize(PollRepository repository) async {
    if (_isInitialized) return;
    
    _repository = repository;
    
    // Initialiser les notifications locales
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(initSettings);
    _isInitialized = true;
    
    AppLogger.w("Service d'alarme initialisé");
  }

  /// Programme une alarme pour un sondage
  void schedulePollAlarm(Poll poll) {
    if (poll.id == null || poll.isClosed || !_isInitialized) return;
    
    final now = DateTime.now();
    final endTime = poll.endDate;
    
    // Si le sondage est déjà terminé, le fermer immédiatement
    if (endTime.isBefore(now)) {
      _closePollImmediately(poll.id!);
      return;
    }
    
    // Annuler l'alarme existante si elle existe
    _cancelPollAlarm(poll.id!);
    
    // Créer une nouvelle alarme
    final alarm = Alarm(
      id: poll.id!,
      pollId: poll.id!,
      triggerTime: endTime,
    );
    
    // Calculer le délai jusqu'à la fermeture
    final delay = endTime.difference(now);
    
    // Créer le timer
    final timer = Timer(delay, () {
      _triggerAlarm(alarm);
    });
    
    _activeTimers[poll.id!] = timer;
    _activeAlarms[poll.id!] = alarm;
    
    AppLogger.w("Alarme programmée pour le sondage ${poll.id} à ${endTime.toIso8601String()}");
  }

  /// Programme les alarmes pour tous les sondages ouverts
  void scheduleAllPolls(List<Poll> polls) {
    if (!_isInitialized) return;
    
    // Annuler toutes les alarmes existantes
    _cancelAllAlarms();
    
    // Programmer les alarmes pour les sondages ouverts
    for (final poll in polls) {
      if (!poll.isClosed) {
        schedulePollAlarm(poll);
      }
    }
    
    AppLogger.w("Alarmes programmées pour ${polls.where((p) => !p.isClosed).length} sondages ouverts");
  }

  /// Déclenche une alarme
  void _triggerAlarm(Alarm alarm) async {
    try {
      // Fermer le sondage
      await _repository?.closePoll(alarm.pollId);
      
      // Nettoyer les ressources
      _activeTimers.remove(alarm.pollId);
      _activeAlarms.remove(alarm.pollId);
      
      // Envoyer une notification
      await _showPollClosedNotification(alarm.pollId);
      
      AppLogger.w("Sondage ${alarm.pollId} fermé automatiquement");
    } catch (e) {
      AppLogger.e("Erreur lors du déclenchement de l'alarme ${alarm.id}: $e");
    }
  }

  /// Ferme immédiatement un sondage
  void _closePollImmediately(String pollId) async {
    try {
      await _repository?.closePoll(pollId);
      AppLogger.w("Sondage $pollId fermé immédiatement (date de fin dépassée)");
    } catch (e) {
      AppLogger.e("Erreur lors de la fermeture immédiate du sondage $pollId: $e");
    }
  }

  /// Annule l'alarme d'un sondage
  void _cancelPollAlarm(String pollId) {
    final timer = _activeTimers.remove(pollId);
    _activeAlarms.remove(pollId);
    timer?.cancel();
  }

  /// Annule toutes les alarmes actives
  void _cancelAllAlarms() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _activeAlarms.clear();
  }

  /// Affiche une notification locale
  Future<void> _showPollClosedNotification(String pollId) async {
    const androidDetails = AndroidNotificationDetails(
      'poll_closures',
      'Fermetures de sondages',
      channelDescription: 'Notifications de fermeture automatique des sondages',
      importance: Importance.low,
      priority: Priority.low,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _notifications.show(
      pollId.hashCode,
      'Sondage fermé',
      'Un sondage vient de se fermer automatiquement',
      details,
    );
  }

  /// Retourne toutes les alarmes actives
  List<Alarm> get activeAlarms => _activeAlarms.values.toList();

  /// Retourne le nombre d'alarmes actives
  int get activeAlarmsCount => _activeAlarms.length;

  /// Nettoie les ressources
  void dispose() {
    _cancelAllAlarms();
    _isInitialized = false;
  }
} 