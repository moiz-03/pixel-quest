import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/utils/suggestion_cooldown.dart';

void main() {
  group('SuggestionCooldown.isActive', () {
    final now = DateTime(2026, 10, 13, 15, 0);

    test('null → not active', () {
      expect(SuggestionCooldown.isActive(null, now: now), isFalse);
    });

    test('empty → not active', () {
      expect(SuggestionCooldown.isActive('', now: now), isFalse);
    });

    test('malformed → not active', () {
      expect(SuggestionCooldown.isActive('garbage', now: now), isFalse);
    });

    test('dismissed today → active', () {
      expect(SuggestionCooldown.isActive('2026-10-13', now: now), isTrue);
    });

    test('dismissed 1 day ago → active', () {
      expect(SuggestionCooldown.isActive('2026-10-12', now: now), isTrue);
    });

    test('dismissed 13 days ago → active', () {
      expect(SuggestionCooldown.isActive('2026-09-30', now: now), isTrue);
    });

    test('dismissed 14 days ago → not active (boundary)', () {
      // 2026-10-13 minus 14 days = 2026-09-29
      expect(SuggestionCooldown.isActive('2026-09-29', now: now), isFalse);
    });

    test('dismissed 30 days ago → not active', () {
      expect(SuggestionCooldown.isActive('2026-09-13', now: now), isFalse);
    });

    test('time of day does not matter — same-day dismissal is active', () {
      final dismissal = DateTime(2026, 10, 13, 23, 59);
      expect(SuggestionCooldown.isActive('2026-10-13', now: dismissal), isTrue);
    });
  });
}
