import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/constants/xp_constants.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/utils/xp_calculator.dart';

Quest _quest(String id, int xp, {List<String>? dates}) => Quest(
  id: id,
  title: 'quest $id',
  category: QuestCategory.health,
  xp: xp,
  completedDates: dates,
);

void main() {
  group('XpCalculator.computeTotalXp', () {
    test('empty list → 0', () {
      expect(XpCalculator.computeTotalXp([]), 0);
    });

    test('quests with no completions → 0', () {
      final quests = [_quest('1', 50), _quest('2', 100)];
      expect(XpCalculator.computeTotalXp(quests), 0);
    });

    test('single completion counts once', () {
      final quests = [
        _quest('1', 50, dates: ['2026-10-13']),
      ];
      expect(XpCalculator.computeTotalXp(quests), 50);
    });

    test('multiple completions multiply xp', () {
      final quests = [
        _quest('1', 50, dates: ['2026-10-01', '2026-10-02', '2026-10-03']),
      ];
      expect(XpCalculator.computeTotalXp(quests), 150);
    });

    test('sums across multiple quests', () {
      final quests = [
        _quest('1', 50, dates: ['2026-10-01', '2026-10-02']), // 100
        _quest('2', 100, dates: ['2026-10-01']), // 100
        _quest('3', 200), // 0
        _quest(
          '4',
          25,
          dates: ['2026-10-01', '2026-10-02', '2026-10-03'],
        ), // 75
      ];
      expect(XpCalculator.computeTotalXp(quests), 275);
    });
  });

  group('XpCalculator.recomputeLevel', () {
    test('0 xp → level 0, 0/100', () {
      final xp = XpCalculator.recomputeLevel(0);
      expect(xp.level, 0);
      expect(xp.currentXp, 0);
      expect(xp.xpToNext, XpConstants.startingXpToNext);
    });

    test('just below first threshold → still level 0', () {
      final xp = XpCalculator.recomputeLevel(99);
      expect(xp.level, 0);
      expect(xp.currentXp, 99);
      expect(xp.xpToNext, 100);
    });

    test('exactly at first threshold → level 1, current resets to 0', () {
      final xp = XpCalculator.recomputeLevel(100);
      expect(xp.level, 1);
      expect(xp.currentXp, 0);
      expect(xp.xpToNext, 150);
    });

    test('mid level 1 → level 1 with carry-over', () {
      final xp = XpCalculator.recomputeLevel(160);
      expect(xp.level, 1);
      expect(xp.currentXp, 60);
      expect(xp.xpToNext, 150);
    });

    test('exactly at second threshold → level 2', () {
      final xp = XpCalculator.recomputeLevel(250);
      expect(xp.level, 2);
      expect(xp.currentXp, 0);
      expect(xp.xpToNext, 200);
    });

    test('exactly at third threshold → level 3', () {
      final xp = XpCalculator.recomputeLevel(450);
      expect(xp.level, 3);
      expect(xp.currentXp, 0);
      expect(xp.xpToNext, 250);
    });

    test('large xp advances many levels', () {
      final xp = XpCalculator.recomputeLevel(1750);
      expect(xp.level, 7);
      expect(xp.currentXp, 0);
      expect(xp.xpToNext, 100 + 7 * 50);
    });

    test('crossing multiple thresholds in one call', () {
      final xp = XpCalculator.recomputeLevel(1360);
      expect(xp.level, 6);
      expect(xp.currentXp, 10);
      expect(xp.xpToNext, 100 + 6 * 50);
    });

    // test/xp_calculator_test.dart (add to existing)
    test('recomputeLevel clamps negative totalXp', () {
      final result = XpCalculator.recomputeLevel(-100);
      expect(result.level, 0);
      expect(result.currentXp, 0);
      expect(result.xpToNext, XpConstants.startingXpToNext);
    });
  });

  group('recomputeLevel — negative / boundary', () {
    test('negative totalXp clamps to level 0, 0 XP, starting xpToNext', () {
      final r = XpCalculator.recomputeLevel(-100);
      expect(r.level, 0);
      expect(r.currentXp, 0);
      expect(r.xpToNext, XpConstants.startingXpToNext);
    });

    test('zero totalXp returns starting state', () {
      final r = XpCalculator.recomputeLevel(0);
      expect(r.level, 0);
      expect(r.currentXp, 0);
      expect(r.xpToNext, XpConstants.startingXpToNext);
    });

    test('exact boundary — 100 XP is level 1 with 0 current', () {
      final r = XpCalculator.recomputeLevel(100);
      expect(r.level, 1);
      expect(r.currentXp, 0);
      expect(r.xpToNext, 150);
    });
  });
}
