/// Determines whether a dismissed suggestion should still be suppressed.
class SuggestionCooldown {
  const SuggestionCooldown._();

  /// How many days to wait before re-suggesting after a dismissal.
  static const int cooldownDays = 14;

  /// True if a suggestion dismissed on [dismissedDate] should still be
  /// suppressed as of [now].
  ///
  /// Returns false when [dismissedDate] is null, empty, or malformed —
  /// i.e. no previous dismissal, so the suggestion may be shown.
  static bool isActive(String? dismissedDate, {DateTime? now}) {
    if (dismissedDate == null || dismissedDate.isEmpty) return false;

    final dismissed = DateTime.tryParse(dismissedDate);
    if (dismissed == null) return false;

    final ref = now ?? DateTime.now();
    final refDay = DateTime(ref.year, ref.month, ref.day);
    final dismissedDay = DateTime(
      dismissed.year,
      dismissed.month,
      dismissed.day,
    );

    final daysSince = refDay.difference(dismissedDay).inDays;
    return daysSince < cooldownDays;
  }
}
