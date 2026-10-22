import '../models/quest.dart';
import 'date_helper.dart';

/// Pure stat derivation from quest + streak data.
/// All methods are synchronous and side-effect free.
class StatsCalculator {
  const StatsCalculator._();

  /// Map of ISO date → number of quests completed on that date.
  /// Only includes dates with at least 1 completion.
  static Map<String, int> completionsByDate(List<Quest> quests) {
    final out = <String, int>{};
    for (final q in quests) {
      for (final d in q.completedDates) {
        out[d] = (out[d] ?? 0) + 1;
      }
    }
    return out;
  }

  /// List of (date, count) for the last [days] days ending today.
  /// Index 0 = oldest, last index = today. Includes zero-count days.
  static List<({String iso, int count})> lastNDays(
    List<Quest> quests, {
    required int days,
    DateTime? now,
  }) {
    final counts = completionsByDate(quests);
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);

    final result = <({String iso, int count})>[];
    for (var i = days - 1; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final iso = DateHelper.isoForDate(d);
      result.add((iso: iso, count: counts[iso] ?? 0));
    }
    return result;
  }

  /// Returns every day in the current calendar month, oldest first.
  /// Each entry has an ISO date and a completion count (0 if none).
  ///
  /// Includes future days within the month (count 0) so the grid is
  /// a stable rectangle even mid-month.
  static List<({String iso, int count})> currentMonthDays(
    List<Quest> quests, {
    DateTime? now,
  }) {
    final counts = completionsByDate(quests);
    final ref = now ?? DateTime.now();
    final daysInMonth = DateTime(ref.year, ref.month + 1, 0).day;

    final result = <({String iso, int count})>[];
    for (var day = 1; day <= daysInMonth; day++) {
      final d = DateTime(ref.year, ref.month, day);
      final iso = DateHelper.isoForDate(d);
      result.add((iso: iso, count: counts[iso] ?? 0));
    }
    return result;
  }

  /// Sum of all completedDates across every quest.
  static int totalCompletions(List<Quest> quests) =>
      quests.fold(0, (sum, q) => sum + q.completedDates.length);

  /// Longest run of consecutive days in the given [activeDates].
  static int longestStreak(Set<String> activeDates) {
    if (activeDates.isEmpty) return 0;
    final sorted = activeDates.toList()..sort();

    int longest = 1;
    int current = 1;

    for (var i = 1; i < sorted.length; i++) {
      final prev = DateTime.tryParse(sorted[i - 1]);
      final curr = DateTime.tryParse(sorted[i]);
      if (prev == null || curr == null) continue;

      final diff = curr.difference(prev).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  /// Completion counts per ISO weekday (1=Mon … 7=Sun).
  static Map<int, int> completionsByWeekday(List<Quest> quests) {
    final out = <int, int>{for (var i = 1; i <= 7; i++) i: 0};
    for (final q in quests) {
      for (final d in q.completedDates) {
        final dt = DateTime.tryParse(d);
        if (dt == null) continue;
        out[dt.weekday] = (out[dt.weekday] ?? 0) + 1;
      }
    }
    return out;
  }

  /// Weekday (1-7) with the most completions, or null if none.
  static int? bestWeekday(List<Quest> quests) {
    final map = completionsByWeekday(quests);
    int? best;
    int bestCount = 0;
    map.forEach((day, count) {
      if (count > bestCount) {
        bestCount = count;
        best = day;
      }
    });
    return best;
  }

  /// Short label for a weekday 1-7. Empty string if out of range.
  static String weekdayName(int weekday) {
    const names = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    if (weekday < 1 || weekday > 7) return '';
    return names[weekday - 1];
  }

  /// Top N quests by completion count. Excludes quests with zero completions.
  static List<Quest> topQuests(List<Quest> quests, {int limit = 3}) {
    final sorted = [...quests]
      ..sort(
        (a, b) => b.completedDates.length.compareTo(a.completedDates.length),
      );
    return sorted
        .where((q) => q.completedDates.isNotEmpty)
        .take(limit)
        .toList();
  }

  /// Completions grouped by category. Excludes categories with zero
  /// completions.
  static Map<QuestCategory, int> categoryBreakdown(List<Quest> quests) {
    final out = <QuestCategory, int>{};
    for (final q in quests) {
      final count = q.completedDates.length;
      if (count == 0) continue;
      out[q.category] = (out[q.category] ?? 0) + count;
    }
    return out;
  }
}
