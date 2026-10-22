import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/utils/next_reminder_time.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));
  });

  group('nextReminderTime across DST (America/New_York)', () {
    test(
      'spring forward: 02:30 does not exist, resolves to a valid instant',
      () {
        // 2026-03-08 is US DST start. 02:00 → 03:00.
        final from = tz.TZDateTime(tz.local, 2026, 3, 8, 1, 30);
        final next = nextReminderTime(2, 30, from: from);

        expect(next.isAfter(from), isTrue);
        expect(next.year, 2026);
        expect(next.month, 3);
      },
    );

    test('fall back: 01:30 is ambiguous, resolves to a valid instant', () {
      // 2026-11-01 is US DST end. 01:00–01:59 happens twice.
      final from = tz.TZDateTime(tz.local, 2026, 11, 1, 0, 30);
      final next = nextReminderTime(1, 30, from: from);

      expect(next.isAfter(from), isTrue);
      expect(next.year, 2026);
      expect(next.month, 11);
      expect(next.day, 1);
    });

    test('normal mid-year day is unaffected by DST', () {
      final from = tz.TZDateTime(tz.local, 2026, 6, 15, 10, 0);
      final next = nextReminderTime(14, 0, from: from);

      expect(next.year, 2026);
      expect(next.month, 6);
      expect(next.day, 15);
      expect(next.hour, 14);
      expect(next.minute, 0);
    });
  });
}
