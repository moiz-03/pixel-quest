import 'date_helper.dart';

/// Result of evaluating whether a freeze should be consumed.
enum FreezeDecision {
  /// User was active today or yesterday. No action.
  noAction,

  /// User missed one day and has a freeze. Consume it.
  consume,

  /// User missed one day but has no freeze. Streak breaks.
  breakNoFreeze,

  /// User missed 2+ days. Streak breaks.
  breakTooLong,

  /// Never active. Nothing to preserve.
  noHistory,
}

class StreakFreeze {
  const StreakFreeze._();

  static FreezeDecision decide({
    required String? lastActive,
    required int freezesOwned,
    DateTime? now,
  }) {
    if (lastActive == null) return FreezeDecision.noHistory;

    final ref = now ?? DateTime.now();
    final today = DateHelper.isoForDate(ref);
    final yesterday = DateHelper.isoForDate(
      ref.subtract(const Duration(days: 1)),
    );
    final twoDaysAgo = DateHelper.isoForDate(
      ref.subtract(const Duration(days: 2)),
    );

    if (lastActive == today || lastActive == yesterday) {
      return FreezeDecision.noAction;
    }
    if (lastActive == twoDaysAgo && freezesOwned > 0) {
      return FreezeDecision.consume;
    }
    if (lastActive == twoDaysAgo) return FreezeDecision.breakNoFreeze;
    return FreezeDecision.breakTooLong;
  }
}
