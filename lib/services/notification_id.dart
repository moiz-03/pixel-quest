/// Stable 32-bit int id derived from a quest id string.
///
/// Uses an explicit FNV-style hash instead of `String.hashCode` because
/// the latter is not guaranteed stable across Dart SDK / app versions,
/// which would break cancellation of previously-scheduled reminders.
int notificationIdFor(String questId) {
  var h = 0;
  for (final c in questId.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return h;
}

/// Stable snooze notification id for [questId].
///
/// Uses a distinct ID space from [notificationIdFor] so a quest's daily
/// reminder and its snooze are two separate notifications that can coexist.
///
/// Both the foreground `NotificationService._scheduleSnooze` and the
/// background `notification_action_handler.dart` MUST derive snooze IDs
/// through this function — otherwise a snooze scheduled from one path
/// cannot be cancelled or overwritten by the other.
int snoozeNotificationIdFor(String questId) =>
    notificationIdFor('snooze_$questId');
