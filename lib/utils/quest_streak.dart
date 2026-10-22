import '../models/quest.dart';
import 'date_helper.dart';

/// Returns the number of consecutive days ending today (or [fromDate])
/// on which the quest was completed.
///
/// A streak is only "active" if it includes today. If the quest was
/// completed yesterday but not today, this returns 0.
///
/// Examples (today = 2026-10-13):
///   completedDates = [10-11, 10-12, 10-13]  →  3
///   completedDates = [10-11, 10-12]          →  0
///   completedDates = [10-10, 10-12, 10-13]  →  2   (gap on 10-11)
///   completedDates = []                      →  0
int questStreak(Quest quest, {DateTime? fromDate}) {
  final start = fromDate ?? DateTime.now();
  int count = 0;
  var cursor = DateTime(start.year, start.month, start.day);

  while (true) {
    final iso = DateHelper.isoForDate(cursor);
    if (!quest.completedDates.contains(iso)) break;
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
}
