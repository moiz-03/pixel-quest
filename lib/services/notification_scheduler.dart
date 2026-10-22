import '../models/quest.dart';

/// The subset of notification behavior [HomeViewModel] depends on.
///
/// [NotificationService] implements this interface in production.
/// Tests use a lightweight fake — no plugin, no platform channels.
abstract class NotificationScheduler {
  Future<void> scheduleQuestReminder(Quest quest);
  Future<void> cancelQuestReminder(String questId);
  Future<void> cancelAll();
  Future<void> rescheduleAllForQuests(List<Quest> quests);
}
