import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/utils/quest_streak.dart';

Quest _q(List<String> dates) => Quest(
  id: '1',
  title: 'x',
  category: QuestCategory.health,
  xp: 10,
  completedDates: dates,
);

void main() {
  group('questStreak', () {
    final today = DateTime(2026, 10, 13);

    test('no completions → 0', () {
      expect(questStreak(_q([]), fromDate: today), 0);
    });

    test('completed today only → 1', () {
      expect(questStreak(_q(['2026-10-13']), fromDate: today), 1);
    });

    test('3 consecutive days ending today → 3', () {
      expect(
        questStreak(
          _q(['2026-10-11', '2026-10-12', '2026-10-13']),
          fromDate: today,
        ),
        3,
      );
    });

    test('7 consecutive days → 7', () {
      final dates = [
        '2026-10-07',
        '2026-10-08',
        '2026-10-09',
        '2026-10-10',
        '2026-10-11',
        '2026-10-12',
        '2026-10-13',
      ];
      expect(questStreak(_q(dates), fromDate: today), 7);
    });

    test('yesterday but not today → 0', () {
      expect(questStreak(_q(['2026-10-11', '2026-10-12']), fromDate: today), 0);
    });

    test('gap yesterday breaks the streak', () {
      // Completed 10-10, missed 10-11, then 10-12 and 10-13
      expect(
        questStreak(
          _q(['2026-10-10', '2026-10-12', '2026-10-13']),
          fromDate: today,
        ),
        2,
      );
    });

    test('future dates are ignored', () {
      expect(
        questStreak(
          _q(['2026-10-13', '2026-10-14', '2026-10-15']),
          fromDate: today,
        ),
        1,
      );
    });

    test('crosses month boundary', () {
      expect(
        questStreak(
          _q(['2026-09-30', '2026-10-01']),
          fromDate: DateTime(2026, 10, 1),
        ),
        2,
      );
    });

    test('crosses year boundary', () {
      expect(
        questStreak(
          _q(['2025-12-31', '2026-01-01']),
          fromDate: DateTime(2026, 1, 1),
        ),
        2,
      );
    });

    test('duplicate dates do not inflate the count', () {
      expect(
        questStreak(
          _q(['2026-10-13', '2026-10-13', '2026-10-12']),
          fromDate: today,
        ),
        2,
      );
    });
  });
}
