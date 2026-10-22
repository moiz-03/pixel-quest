import 'package:timezone/timezone.dart' as tz;

/// Returns the next occurrence of [hour]:[minute] in the local timezone.
/// If today's time has already passed, returns tomorrow's.
///
/// Extracted as a top-level function so it can be unit tested without
/// touching the notification plugin.
tz.TZDateTime nextReminderTime(int hour, int minute, {tz.TZDateTime? from}) {
  final now = from ?? tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  if (!scheduled.isAfter(now)) {
    // Calendar-day rollover (not duration rollover). On DST transition
    // days a "day" is 23 or 25 wall-clock hours, so `add(Duration(days: 1))`
    // would shift the reminder by ±1 hour. The TZDateTime constructor
    // handles day-rollover correctly including month/year/leap bounds.
    scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      hour,
      minute,
    );
  }
  return scheduled;
}
