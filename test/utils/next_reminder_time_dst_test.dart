import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/utils/next_reminder_time.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location originalLocal;

  setUpAll(tz.initializeTimeZones);

  setUp(() {
    originalLocal = tz.local;
    tz.setLocalLocation(tz.getLocation('America/New_York'));
  });

  tearDown(() {
    tz.setLocalLocation(originalLocal);
  });

  tz.TZDateTime ny(int y, int m, int d, int h, int min) =>
      tz.TZDateTime(tz.getLocation('America/New_York'), y, m, d, h, min);

  group('nextReminderTime — DST transitions (America/New_York)', () {
    test('spring-forward: past-time rolls to tomorrow at same wall clock', () {
      // 2025-03-09 02:00 EST → 03:00 EDT. from is 23:00 on Mar 8 (EST),
      // reminder is 22:00 (past). Next fire must be 2025-03-09 22:00 EDT.
      final from = ny(2025, 3, 8, 23, 0);
      expect(from.timeZoneOffset, const Duration(hours: -5)); // EST
      final next = nextReminderTime(22, 0, from: from);

      expect(next.year, 2025);
      expect(next.month, 3);
      expect(next.day, 9);
      expect(next.hour, 22); // MUST be 22:00, not 23:00
      expect(next.minute, 0);
      expect(next.timeZoneOffset, const Duration(hours: -4)); // EDT
    });

    test('fall-back: past-time rolls to tomorrow at same wall clock', () {
      // 2025-11-02 02:00 EDT → 01:00 EST. from is 23:30 on Nov 1 (EDT),
      // reminder is 22:00 (past). Next fire must be 2025-11-02 22:00 EST.
      final from = ny(2025, 11, 1, 23, 30);
      expect(from.timeZoneOffset, const Duration(hours: -4)); // EDT
      final next = nextReminderTime(22, 0, from: from);

      expect(next.year, 2025);
      expect(next.month, 11);
      expect(next.day, 2);
      expect(next.hour, 22); // MUST be 22:00, not 21:00 or 23:00
      expect(next.minute, 0);
      expect(next.timeZoneOffset, const Duration(hours: -5)); // EST
    });

    test('regression: wall clock unchanged after DST, not shifted by 1h', () {
      // Same test as above, but focused purely on the hour value.
      // This is the exact regression the fix targets.
      final from = ny(2025, 11, 2, 23, 0);
      final next = nextReminderTime(22, 0, from: from);
      expect(next.hour, 22);
      expect(next.day, 3);
    });

    test('past-time crossing month-end', () {
      // 2026-01-31 23:00 → 2026-02-01 22:00
      final next = nextReminderTime(22, 0, from: ny(2026, 1, 31, 23, 0));
      expect(next.year, 2026);
      expect(next.month, 2);
      expect(next.day, 1);
      expect(next.hour, 22);
    });

    test('past-time crossing year-end', () {
      final next = nextReminderTime(22, 0, from: ny(2026, 12, 31, 23, 0));
      expect(next.year, 2027);
      expect(next.month, 1);
      expect(next.day, 1);
      expect(next.hour, 22);
    });

    test('past-time on leap day crosses to Mar 1', () {
      final next = nextReminderTime(22, 0, from: ny(2024, 2, 29, 23, 0));
      expect(next.year, 2024);
      expect(next.month, 3);
      expect(next.day, 1);
    });

    test('future today is unchanged (regression)', () {
      final next = nextReminderTime(14, 0, from: ny(2026, 6, 1, 10, 0));
      expect(next.day, 1);
      expect(next.hour, 14);
    });

    test('exactly now → tomorrow (regression)', () {
      final next = nextReminderTime(14, 0, from: ny(2026, 6, 1, 14, 0));
      expect(next.day, 2);
    });
  });
}
