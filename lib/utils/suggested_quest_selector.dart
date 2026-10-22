import '../models/quest.dart';
import 'quest_streak.dart';
import 'suggestion_cooldown.dart';

/// Threshold: how many consecutive days must be completed before a
/// reminder suggestion is offered.
const int kSuggestionStreakThreshold = 3;

/// Returns the first quest that should be suggested for a reminder, or null.
///
/// A quest qualifies if:
///   1. It has no reminder set (`reminderTime == null`)
///   2. It hasn't been dismissed within the cooldown window
///   3. It has a streak of at least [threshold] consecutive days ending today
///
/// [dismissals] maps questId → ISO date the user dismissed a suggestion for it.
Quest? selectSuggestedQuest(
  List<Quest> quests,
  Map<String, String> dismissals, {
  int threshold = kSuggestionStreakThreshold,
  DateTime? now,
}) {
  for (final q in quests) {
    if (q.reminderTime != null) continue;

    final dismissed = dismissals[q.id];
    if (SuggestionCooldown.isActive(dismissed, now: now)) continue;

    if (questStreak(q, fromDate: now) >= threshold) return q;
  }
  return null;
}
