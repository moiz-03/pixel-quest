import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/utils/date_helper.dart';

void main() {
  group('DateHelper.todayIso', () {
    test('returns YYYY-MM-DD', () {
      expect(DateHelper.todayIso(), matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });

    test('matches the current date', () {
      final now = DateTime.now();
      final expected =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      expect(DateHelper.todayIso(), expected);
    });

    test('always pads month and day to 2 digits', () {
      final iso = DateHelper.todayIso();
      expect(iso.substring(5, 7).length, 2);
      expect(iso.substring(8, 10).length, 2);
    });
  });

  group('DateHelper.yesterdayIso', () {
    test('returns YYYY-MM-DD', () {
      expect(
        DateHelper.yesterdayIso(),
        matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
      );
    });

    test('matches exactly one day before today', () {
      final y = DateTime.now().subtract(const Duration(days: 1));
      final expected =
          '${y.year.toString().padLeft(4, '0')}-'
          '${y.month.toString().padLeft(2, '0')}-'
          '${y.day.toString().padLeft(2, '0')}';
      expect(DateHelper.yesterdayIso(), expected);
    });
  });

  group('DateHelper.isoForDate', () {
    test('formats 2026-03-05', () {
      expect(DateHelper.isoForDate(DateTime(2026, 3, 5)), '2026-03-05');
    });

    test('pads month and day', () {
      expect(DateHelper.isoForDate(DateTime(2026, 1, 2)), '2026-01-02');
    });

    test('handles December 31', () {
      expect(DateHelper.isoForDate(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('todayIso matches isoForDate(DateTime.now())', () {
      expect(DateHelper.todayIso(), DateHelper.isoForDate(DateTime.now()));
    });
  });
}
