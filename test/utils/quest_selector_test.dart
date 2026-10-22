import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/utils/suggested_quest_selector.dart';

Quest _quest(String id, {List<String>? dates, String? reminder}) => Quest(
  id: id,
  title: 'quest $id',
  category: QuestCategory.health,
  xp: 10,
  completedDates: dates ?? [],
  reminderTime: reminder,
);

void main() {
  // Fixed "today" for all tests
  final today = DateTime(2026, 10, 13);

  // Helper: ISO strings for the 3 days ending "today"
  const d1 = '2026-10-11';
  const d2 = '2026-10-12';
  const d3 = '2026-10-13';
  const threeDayStreak = [d1, d2, d3];

  group('selectSuggestedQuest', () {
    test('empty list → null', () {
      expect(selectSuggestedQuest([], {}, now: today), isNull);
    });

    test('quest with no completions → null', () {
      expect(selectSuggestedQuest([_quest('a')], {}, now: today), isNull);
    });

    test('quest with 2-day streak → null', () {
      expect(
        selectSuggestedQuest(
          [
            _quest('a', dates: [d2, d3]),
          ],
          {},
          now: today,
        ),
        isNull,
      );
    });

    test('quest with 3-day streak → returned', () {
      final q = _quest('a', dates: threeDayStreak);
      expect(selectSuggestedQuest([q], {}, now: today), same(q));
    });

    test('quest with 5-day streak → returned', () {
      final q = _quest(
        'a',
        dates: ['2026-10-09', '2026-10-10', ...threeDayStreak],
      );
      expect(selectSuggestedQuest([q], {}, now: today), same(q));
    });

    test('quest with reminder set → skipped', () {
      final q = _quest('a', dates: threeDayStreak, reminder: '20:00');
      expect(selectSuggestedQuest([q], {}, now: today), isNull);
    });

    test('quest with gap in streak → null', () {
      // Completed 2 days ago, missed yesterday, completed today
      final q = _quest('a', dates: ['2026-10-11', d3]);
      expect(selectSuggestedQuest([q], {}, now: today), isNull);
    });

    test('quest with streak ending yesterday (not today) → null', () {
      final q = _quest('a', dates: [d1, d2]);
      expect(selectSuggestedQuest([q], {}, now: today), isNull);
    });

    test('dismissed within cooldown → null', () {
      final q = _quest('a', dates: threeDayStreak);
      // Dismissed 5 days ago (still inside 14-day window)
      final dismissals = {'a': '2026-10-08'};
      expect(selectSuggestedQuest([q], dismissals, now: today), isNull);
    });

    test('dismissed outside cooldown → returned', () {
      final q = _quest('a', dates: threeDayStreak);
      // Dismissed exactly 14 days ago → cooldown expired
      final dismissals = {'a': '2026-09-29'};
      expect(selectSuggestedQuest([q], dismissals, now: today), same(q));
    });

    test('dismissal date is malformed → treated as no dismissal', () {
      final q = _quest('a', dates: threeDayStreak);
      final dismissals = {'a': 'not-a-date'};
      expect(selectSuggestedQuest([q], dismissals, now: today), same(q));
    });

    test('dismissal for a different quest → no effect', () {
      final q = _quest('a', dates: threeDayStreak);
      final dismissals = {'b': '2026-10-12'};
      expect(selectSuggestedQuest([q], dismissals, now: today), same(q));
    });

    test('multiple qualifiers → returns first in list order', () {
      final first = _quest('a', dates: threeDayStreak);
      final second = _quest('b', dates: threeDayStreak);
      expect(
        selectSuggestedQuest([first, second], {}, now: today),
        same(first),
      );
    });

    test('first has reminder → returns second', () {
      final first = _quest('a', dates: threeDayStreak, reminder: '20:00');
      final second = _quest('b', dates: threeDayStreak);
      expect(
        selectSuggestedQuest([first, second], {}, now: today),
        same(second),
      );
    });

    test('first dismissed → returns second', () {
      final first = _quest('a', dates: threeDayStreak);
      final second = _quest('b', dates: threeDayStreak);
      final dismissals = {'a': '2026-10-13'};
      expect(
        selectSuggestedQuest([first, second], dismissals, now: today),
        same(second),
      );
    });

    test('first has 2-day streak → returns second', () {
      final first = _quest('a', dates: [d2, d3]);
      final second = _quest('b', dates: threeDayStreak);
      expect(
        selectSuggestedQuest([first, second], {}, now: today),
        same(second),
      );
    });

    test('all disqualified → null', () {
      final a = _quest('a', dates: threeDayStreak, reminder: '20:00');
      final b = _quest('b', dates: [d2, d3]); // 2-day streak
      final c = _quest('c'); // no completions
      expect(selectSuggestedQuest([a, b, c], {}, now: today), isNull);
    });

    test('custom threshold of 1 → any completed-today quest qualifies', () {
      final q = _quest('a', dates: [d3]);
      expect(selectSuggestedQuest([q], {}, threshold: 1, now: today), same(q));
    });

    test('custom threshold of 5 → 3-day streak does not qualify', () {
      final q = _quest('a', dates: threeDayStreak);
      expect(selectSuggestedQuest([q], {}, threshold: 5, now: today), isNull);
    });
  });
}
