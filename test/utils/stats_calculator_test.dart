import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/utils/stats_calculator.dart';

Quest _q(
  String id, {
  List<String>? dates,
  QuestCategory category = QuestCategory.health,
}) => Quest(
  id: id,
  title: 'quest $id',
  category: category,
  xp: 10,
  completedDates: dates ?? [],
);

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // completionsByDate
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.completionsByDate', () {
    test('empty quests → empty map', () {
      expect(StatsCalculator.completionsByDate([]), isEmpty);
    });

    test('quests with no completions → empty map', () {
      expect(StatsCalculator.completionsByDate([_q('a'), _q('b')]), isEmpty);
    });

    test('single completion → one entry', () {
      final result = StatsCalculator.completionsByDate([
        _q('a', dates: ['2026-10-13']),
      ]);
      expect(result, {'2026-10-13': 1});
    });

    test('two quests on the same day → count 2', () {
      final result = StatsCalculator.completionsByDate([
        _q('a', dates: ['2026-10-13']),
        _q('b', dates: ['2026-10-13']),
      ]);
      expect(result, {'2026-10-13': 2});
    });

    test('multiple days aggregate correctly', () {
      final result = StatsCalculator.completionsByDate([
        _q('a', dates: ['2026-10-13', '2026-10-12']),
        _q('b', dates: ['2026-10-13', '2026-10-11']),
      ]);
      expect(result, {'2026-10-13': 2, '2026-10-12': 1, '2026-10-11': 1});
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // lastNDays
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.lastNDays', () {
    final now = DateTime(2026, 10, 13);

    test('returns exactly N entries', () {
      expect(StatsCalculator.lastNDays([], days: 7, now: now).length, 7);
      expect(StatsCalculator.lastNDays([], days: 30, now: now).length, 30);
    });

    test('last entry is today', () {
      final result = StatsCalculator.lastNDays([], days: 7, now: now);
      expect(result.last.iso, '2026-10-13');
    });

    test('first entry is N-1 days ago', () {
      final result = StatsCalculator.lastNDays([], days: 7, now: now);
      expect(result.first.iso, '2026-10-07');
    });

    test('days with no completions have count 0', () {
      final result = StatsCalculator.lastNDays([], days: 7, now: now);
      expect(result.every((d) => d.count == 0), isTrue);
    });

    test('counts on the right days', () {
      final result = StatsCalculator.lastNDays(
        [
          _q('a', dates: ['2026-10-13', '2026-10-11']),
          _q('b', dates: ['2026-10-13']),
        ],
        days: 7,
        now: now,
      );
      final byIso = {for (final d in result) d.iso: d.count};
      expect(byIso['2026-10-13'], 2);
      expect(byIso['2026-10-12'], 0);
      expect(byIso['2026-10-11'], 1);
    });

    test('completions outside the window are excluded', () {
      final result = StatsCalculator.lastNDays(
        [
          _q('a', dates: ['2026-01-01']),
        ],
        days: 7,
        now: now,
      );
      expect(result.every((d) => d.count == 0), isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // currentMonthDays
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.currentMonthDays', () {
    test('October 2026 has 31 days', () {
      final result = StatsCalculator.currentMonthDays(
        [],
        now: DateTime(2026, 10, 14),
      );
      expect(result.length, 31);
      expect(result.first.iso, '2026-10-01');
      expect(result.last.iso, '2026-10-31');
    });

    test('February 2026 (non-leap) has 28 days', () {
      final result = StatsCalculator.currentMonthDays(
        [],
        now: DateTime(2026, 2, 10),
      );
      expect(result.length, 28);
      expect(result.first.iso, '2026-02-01');
      expect(result.last.iso, '2026-02-28');
    });

    test('February 2024 (leap) has 29 days', () {
      final result = StatsCalculator.currentMonthDays(
        [],
        now: DateTime(2024, 2, 10),
      );
      expect(result.length, 29);
      expect(result.last.iso, '2024-02-29');
    });

    test('April has 30 days', () {
      final result = StatsCalculator.currentMonthDays(
        [],
        now: DateTime(2026, 4, 15),
      );
      expect(result.length, 30);
      expect(result.last.iso, '2026-04-30');
    });

    test('December 2026 has 31 days', () {
      final result = StatsCalculator.currentMonthDays(
        [],
        now: DateTime(2026, 12, 15),
      );
      expect(result.length, 31);
      expect(result.last.iso, '2026-12-31');
    });

    test('January has 31 days', () {
      final result = StatsCalculator.currentMonthDays(
        [],
        now: DateTime(2026, 1, 20),
      );
      expect(result.length, 31);
      expect(result.last.iso, '2026-01-31');
    });

    test('all days of the month are present in order', () {
      final result = StatsCalculator.currentMonthDays(
        [],
        now: DateTime(2026, 10, 14),
      );
      for (var i = 0; i < 31; i++) {
        final expectedDay = (i + 1).toString().padLeft(2, '0');
        expect(result[i].iso, '2026-10-$expectedDay');
      }
    });

    test('counts completions on their dates', () {
      final result = StatsCalculator.currentMonthDays([
        _q('a', dates: ['2026-10-13', '2026-10-14']),
        _q('b', dates: ['2026-10-13']),
      ], now: DateTime(2026, 10, 20));
      final byIso = {for (final d in result) d.iso: d.count};
      expect(byIso['2026-10-13'], 2);
      expect(byIso['2026-10-14'], 1);
      expect(byIso['2026-10-12'], 0);
    });

    test('completions outside the month are excluded', () {
      final result = StatsCalculator.currentMonthDays([
        _q('a', dates: ['2026-09-29', '2026-11-01']),
      ], now: DateTime(2026, 10, 15));
      expect(result.every((d) => d.count == 0), isTrue);
    });

    test('future days within the month are present with count 0', () {
      final result = StatsCalculator.currentMonthDays(
        [],
        now: DateTime(2026, 10, 14),
      );
      final byIso = {for (final d in result) d.iso: d.count};
      expect(byIso['2026-10-20'], 0);
      expect(byIso['2026-10-31'], 0);
    });

    test('all days are zero when no quests have completions', () {
      final result = StatsCalculator.currentMonthDays([
        _q('a'),
        _q('b'),
      ], now: DateTime(2026, 10, 15));
      expect(result.every((d) => d.count == 0), isTrue);
    });

    test('handles month boundary — completions on day 1 and last day', () {
      final result = StatsCalculator.currentMonthDays([
        _q('a', dates: ['2026-10-01', '2026-10-31']),
      ], now: DateTime(2026, 10, 15));
      final byIso = {for (final d in result) d.iso: d.count};
      expect(byIso['2026-10-01'], 1);
      expect(byIso['2026-10-31'], 1);
      expect(byIso['2026-10-15'], 0);
    });

    test('day 15 of a 31-day month is at index 14', () {
      final result = StatsCalculator.currentMonthDays(
        [],
        now: DateTime(2026, 10, 15),
      );
      expect(result[14].iso, '2026-10-15');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // totalCompletions
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.totalCompletions', () {
    test('empty list → 0', () {
      expect(StatsCalculator.totalCompletions([]), 0);
    });

    test('no completions → 0', () {
      expect(StatsCalculator.totalCompletions([_q('a'), _q('b')]), 0);
    });

    test('sums across quests', () {
      expect(
        StatsCalculator.totalCompletions([
          _q('a', dates: ['2026-10-13', '2026-10-12']),
          _q('b', dates: ['2026-10-13']),
        ]),
        3,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // longestStreak
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.longestStreak', () {
    test('empty set → 0', () {
      expect(StatsCalculator.longestStreak({}), 0);
    });

    test('single day → 1', () {
      expect(StatsCalculator.longestStreak({'2026-10-13'}), 1);
    });

    test('three consecutive → 3', () {
      expect(
        StatsCalculator.longestStreak({
          '2026-10-11',
          '2026-10-12',
          '2026-10-13',
        }),
        3,
      );
    });

    test('two separate runs → returns longer', () {
      expect(
        StatsCalculator.longestStreak({
          '2026-10-01',
          '2026-10-02',
          '2026-10-05',
          '2026-10-06',
          '2026-10-07',
        }),
        3,
      );
    });

    test('gap in the middle breaks the streak', () {
      expect(StatsCalculator.longestStreak({'2026-10-11', '2026-10-13'}), 1);
    });

    test('unsorted input still works', () {
      expect(
        StatsCalculator.longestStreak({
          '2026-10-13',
          '2026-10-11',
          '2026-10-12',
        }),
        3,
      );
    });

    test('crosses month boundary', () {
      expect(StatsCalculator.longestStreak({'2026-09-30', '2026-10-01'}), 2);
    });

    test('crosses year boundary', () {
      expect(StatsCalculator.longestStreak({'2025-12-31', '2026-01-01'}), 2);
    });

    test('duplicate inputs collapse in set (no crash)', () {
      final source = ['2026-10-13', '2026-10-13'];
      expect(StatsCalculator.longestStreak(source.toSet()), 1);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // completionsByWeekday
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.completionsByWeekday', () {
    test('empty → all weekdays zero', () {
      final result = StatsCalculator.completionsByWeekday([]);
      for (var i = 1; i <= 7; i++) {
        expect(result[i], 0);
      }
    });

    test('counts by correct weekday', () {
      // 2026-10-13 is a Tuesday (weekday=2)
      final result = StatsCalculator.completionsByWeekday([
        _q('a', dates: ['2026-10-13']),
      ]);
      expect(result[2], 1);
      expect(result[1], 0);
      expect(result[3], 0);
    });

    test('aggregates across quests', () {
      final result = StatsCalculator.completionsByWeekday([
        _q('a', dates: ['2026-10-13']),
        _q('b', dates: ['2026-10-13']),
      ]);
      expect(result[2], 2);
    });

    test('invalid date strings are ignored', () {
      final result = StatsCalculator.completionsByWeekday([
        _q('a', dates: ['not-a-date', '2026-10-13']),
      ]);
      expect(result[2], 1);
    });

    test('all weekdays are always present in the map', () {
      final result = StatsCalculator.completionsByWeekday([]);
      expect(result.keys.toSet(), {1, 2, 3, 4, 5, 6, 7});
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // bestWeekday
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.bestWeekday', () {
    test('no data → null', () {
      expect(StatsCalculator.bestWeekday([]), isNull);
    });

    test('single day → that day', () {
      // 2026-10-13 is Tuesday (weekday=2)
      expect(
        StatsCalculator.bestWeekday([
          _q('a', dates: ['2026-10-13']),
        ]),
        2,
      );
    });

    test('returns the weekday with most completions', () {
      // Monday 2026-10-12, Tuesday 2026-10-13
      final result = StatsCalculator.bestWeekday([
        _q('a', dates: ['2026-10-12', '2026-10-12', '2026-10-13']),
      ]);
      expect(result, 1); // Monday
    });

    test('tie → returns first found (lowest weekday)', () {
      // One completion on Monday and one on Tuesday
      final result = StatsCalculator.bestWeekday([
        _q('a', dates: ['2026-10-12', '2026-10-13']),
      ]);
      expect(result, 1); // Monday wins ties
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // weekdayName
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.weekdayName', () {
    test('1 → MON', () => expect(StatsCalculator.weekdayName(1), 'MON'));
    test('2 → TUE', () => expect(StatsCalculator.weekdayName(2), 'TUE'));
    test('3 → WED', () => expect(StatsCalculator.weekdayName(3), 'WED'));
    test('4 → THU', () => expect(StatsCalculator.weekdayName(4), 'THU'));
    test('5 → FRI', () => expect(StatsCalculator.weekdayName(5), 'FRI'));
    test('6 → SAT', () => expect(StatsCalculator.weekdayName(6), 'SAT'));
    test('7 → SUN', () => expect(StatsCalculator.weekdayName(7), 'SUN'));
    test('0 → empty', () => expect(StatsCalculator.weekdayName(0), ''));
    test('8 → empty', () => expect(StatsCalculator.weekdayName(8), ''));
    test('-1 → empty', () => expect(StatsCalculator.weekdayName(-1), ''));
  });

  // ══════════════════════════════════════════════════════════════════════════
  // topQuests
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.topQuests', () {
    test('empty → []', () {
      expect(StatsCalculator.topQuests([]), isEmpty);
    });

    test('excludes quests with no completions', () {
      final result = StatsCalculator.topQuests([
        _q('a'),
        _q('b', dates: ['2026-10-13']),
      ]);
      expect(result.length, 1);
      expect(result.first.id, 'b');
    });

    test('sorted by completion count descending', () {
      final result = StatsCalculator.topQuests([
        _q('a', dates: ['2026-10-13']),
        _q('b', dates: ['2026-10-13', '2026-10-12', '2026-10-11']),
        _q('c', dates: ['2026-10-13', '2026-10-12']),
      ]);
      expect(result.map((q) => q.id).toList(), ['b', 'c', 'a']);
    });

    test('respects the limit', () {
      final result = StatsCalculator.topQuests([
        _q('a', dates: ['2026-10-13']),
        _q('b', dates: ['2026-10-13']),
        _q('c', dates: ['2026-10-13']),
        _q('d', dates: ['2026-10-13']),
      ], limit: 2);
      expect(result.length, 2);
    });

    test('limit larger than available returns all', () {
      final result = StatsCalculator.topQuests([
        _q('a', dates: ['2026-10-13']),
      ], limit: 10);
      expect(result.length, 1);
    });

    test('default limit is 3', () {
      final result = StatsCalculator.topQuests([
        _q('a', dates: ['2026-10-13']),
        _q('b', dates: ['2026-10-13']),
        _q('c', dates: ['2026-10-13']),
        _q('d', dates: ['2026-10-13']),
        _q('e', dates: ['2026-10-13']),
      ]);
      expect(result.length, 3);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // categoryBreakdown
  // ══════════════════════════════════════════════════════════════════════════
  group('StatsCalculator.categoryBreakdown', () {
    test('empty → {}', () {
      expect(StatsCalculator.categoryBreakdown([]), isEmpty);
    });

    test('excludes zero-completion quests', () {
      final result = StatsCalculator.categoryBreakdown([_q('a')]);
      expect(result, isEmpty);
    });

    test('groups by category', () {
      final result = StatsCalculator.categoryBreakdown([
        _q('a', dates: ['2026-10-13'], category: QuestCategory.health),
        _q('b', dates: ['2026-10-13'], category: QuestCategory.health),
        _q('c', dates: ['2026-10-13'], category: QuestCategory.fitness),
      ]);
      expect(result[QuestCategory.health], 2);
      expect(result[QuestCategory.fitness], 1);
    });

    test('sums completions per category', () {
      final result = StatsCalculator.categoryBreakdown([
        _q(
          'a',
          dates: ['2026-10-13', '2026-10-12', '2026-10-11'],
          category: QuestCategory.fitness,
        ),
      ]);
      expect(result[QuestCategory.fitness], 3);
    });

    test('categories with no completions are excluded', () {
      final result = StatsCalculator.categoryBreakdown([
        _q('a', dates: ['2026-10-13'], category: QuestCategory.health),
        _q('b', category: QuestCategory.fitness),
      ]);
      expect(result.containsKey(QuestCategory.fitness), isFalse);
      expect(result.containsKey(QuestCategory.health), isTrue);
    });
  });
}
