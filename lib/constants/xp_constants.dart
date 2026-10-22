class XpConstants {
  const XpConstants._();

  /// XP required to advance from level 0 → level 1.
  static const int startingXpToNext = 100;

  /// How much `xpToNext` grows with each level-up.
  /// Level 1 needs 150, level 2 needs 200, etc.
  static const int xpGrowthPerLevel = 50;
}
