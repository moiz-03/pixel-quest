import '../models/quest.dart';
import '../constants/xp_constants.dart';

class XpBreakdown {
  final int level;
  final int currentXp;
  final int xpToNext;

  const XpBreakdown({
    required this.level,
    required this.currentXp,
    required this.xpToNext,
  });
}

class XpCalculator {
  const XpCalculator._();

  /// Total XP earned across all quests, counting every historical completion.
  /// A quest completed 10 times contributes `10 × xp`. Levels are therefore
  /// stable day-to-day — they never reset when a new day begins.
  static int computeTotalXp(List<Quest> quests) =>
      quests.fold(0, (sum, q) => sum + q.xp * q.completedDates.length);

  static XpBreakdown recomputeLevel(int totalXp) {
    // Defensive: negative XP (corrupt data, or a caller that forgot the
    // clamp upstream) must not produce a negative `currentXp` — that
    // would render as "-5 XP" in the UI.
    if (totalXp <= 0) {
      return const XpBreakdown(
        level: 0,
        currentXp: 0,
        xpToNext: XpConstants.startingXpToNext,
      );
    }
    int level = 0;
    int remaining = totalXp;
    int toNext = XpConstants.startingXpToNext;
    while (remaining >= toNext) {
      remaining -= toNext;
      level++;
      toNext += XpConstants.xpGrowthPerLevel;
    }
    return XpBreakdown(level: level, currentXp: remaining, xpToNext: toNext);
  }
}
