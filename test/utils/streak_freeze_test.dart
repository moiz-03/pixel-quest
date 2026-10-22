import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/utils/streak_freeze.dart';

void main() {
  final now = DateTime(2026, 10, 14);
  const today = '2026-10-14';
  const yesterday = '2026-10-13';
  const twoDaysAgo = '2026-10-12';
  const threeDaysAgo = '2026-10-11';

  group('StreakFreeze.decide', () {
    test('null lastActive → noHistory', () {
      expect(
        StreakFreeze.decide(lastActive: null, freezesOwned: 0, now: now),
        FreezeDecision.noHistory,
      );
    });

    test('active today → noAction', () {
      expect(
        StreakFreeze.decide(lastActive: today, freezesOwned: 2, now: now),
        FreezeDecision.noAction,
      );
    });

    test('active yesterday → noAction', () {
      expect(
        StreakFreeze.decide(lastActive: yesterday, freezesOwned: 0, now: now),
        FreezeDecision.noAction,
      );
    });

    test('missed 1 day with freeze → consume', () {
      expect(
        StreakFreeze.decide(lastActive: twoDaysAgo, freezesOwned: 1, now: now),
        FreezeDecision.consume,
      );
    });

    test('missed 1 day with 2 freezes → consume', () {
      expect(
        StreakFreeze.decide(lastActive: twoDaysAgo, freezesOwned: 2, now: now),
        FreezeDecision.consume,
      );
    });

    test('missed 1 day with no freeze → breakNoFreeze', () {
      expect(
        StreakFreeze.decide(lastActive: twoDaysAgo, freezesOwned: 0, now: now),
        FreezeDecision.breakNoFreeze,
      );
    });

    test('missed 2 days → breakTooLong', () {
      expect(
        StreakFreeze.decide(
          lastActive: threeDaysAgo,
          freezesOwned: 2,
          now: now,
        ),
        FreezeDecision.breakTooLong,
      );
    });

    test('missed long ago → breakTooLong', () {
      expect(
        StreakFreeze.decide(
          lastActive: '2026-01-01',
          freezesOwned: 2,
          now: now,
        ),
        FreezeDecision.breakTooLong,
      );
    });
  });
}
