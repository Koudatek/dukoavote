import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/alarm_service.dart';
import '../../domain/entities/alarm.dart';
import '../../../polls/domain/entities/poll.dart';

final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService();
});

final activeAlarmsProvider = Provider<List<Alarm>>((ref) {
  final alarmService = ref.watch(alarmServiceProvider);
  return alarmService.activeAlarms;
});

final activeAlarmsCountProvider = Provider<int>((ref) {
  final alarmService = ref.watch(alarmServiceProvider);
  return alarmService.activeAlarmsCount;
});

/// Provider pour initialiser le service d'alarme avec un repository
final alarmInitializerProvider = FutureProvider.family<void, dynamic>((ref, repository) async {
  final alarmService = ref.read(alarmServiceProvider);
  await alarmService.initialize(repository);
});

/// Provider pour programmer les alarmes pour une liste de sondages
final alarmSchedulerProvider = Provider.family<void, List<Poll>>((ref, polls) {
  final alarmService = ref.read(alarmServiceProvider);
  alarmService.scheduleAllPolls(polls);
});

/// Provider pour programmer une alarme pour un sondage spécifique
final singleAlarmSchedulerProvider = Provider.family<void, Poll>((ref, poll) {
  final alarmService = ref.read(alarmServiceProvider);
  alarmService.schedulePollAlarm(poll);
}); 