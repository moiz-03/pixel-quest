import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/utils/next_reminder_time.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('nextReminderTime', () {
    tz.TZDateTime at(int y, int m, int d, int h, int min) =>
        tz.TZDateTime(tz.UTC, y, m, d, h, min);

    test('future time today → same day', () {
      final from = at(2026, 3, 15, 10, 0);
      final next = nextReminderTime(14, 30, from: from);
      expect(next.year, 2026);
      expect(next.month, 3);
      expect(next.day, 15);
      expect(next.hour, 14);
      expect(next.minute, 30);
    });

    test('past time today → tomorrow', () {
      final from = at(2026, 3, 15, 20, 0);
      final next = nextReminderTime(14, 30, from: from);
      expect(next.day, 16);
      expect(next.hour, 14);
      expect(next.minute, 30);
    });

    test('exactly now → tomorrow (must be strictly after)', () {
      final from = at(2026, 3, 15, 14, 30);
      final next = nextReminderTime(14, 30, from: from);
      expect(next.day, 16);
    });

    test('one minute in future → today', () {
      final from = at(2026, 3, 15, 14, 29);
      final next = nextReminderTime(14, 30, from: from);
      expect(next.day, 15);
    });

    test('one minute past → tomorrow', () {
      final from = at(2026, 3, 15, 14, 31);
      final next = nextReminderTime(14, 30, from: from);
      expect(next.day, 16);
    });

    test('midnight in future today', () {
      final from = at(2026, 3, 15, 0, 1);
      final next = nextReminderTime(0, 0, from: from);
      expect(next.day, 16);
    });

    test('end-of-day rolls over', () {
      final from = at(2026, 3, 15, 23, 59);
      final next = nextReminderTime(23, 59, from: from);
      expect(next.day, 16);
    });

    test('crosses month boundary', () {
      final from = at(2026, 3, 31, 23, 0);
      final next = nextReminderTime(1, 0, from: from);
      expect(next.month, 4);
      expect(next.day, 1);
    });

    test('crosses year boundary', () {
      final from = at(2026, 12, 31, 23, 0);
      final next = nextReminderTime(1, 0, from: from);
      expect(next.year, 2027);
      expect(next.month, 1);
      expect(next.day, 1);
    });

    test('handles leap day', () {
      final from = at(2024, 2, 28, 23, 0);
      final next = nextReminderTime(1, 0, from: from);
      expect(next.month, 2);
      expect(next.day, 29);
    });
  });

  group('nextReminderTime — DST and large jumps', () {
    tz.TZDateTime at(int y, int m, int d, int h, int min) =>
        tz.TZDateTime(tz.UTC, y, m, d, h, min);

    test('far future from → same hour today', () {
      final from = at(2026, 6, 1, 3, 0);
      final next = nextReminderTime(5, 0, from: from);
      expect(next.day, 1);
      expect(next.hour, 5);
    });

    test('very early morning vs late hour', () {
      final from = at(2026, 6, 1, 0, 0);
      final next = nextReminderTime(23, 59, from: from);
      expect(next.day, 1);
      expect(next.hour, 23);
      expect(next.minute, 59);
    });

    test('exact hour boundary returns tomorrow if equal', () {
      final from = at(2026, 6, 1, 12, 0);
      final next = nextReminderTime(12, 0, from: from);
      expect(next.day, 2);
      expect(next.hour, 12);
    });
  });
}
