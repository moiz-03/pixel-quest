import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/utils/time_parser.dart';

void main() {
  group('TimeParser.parse', () {
    test('null → null', () {
      expect(TimeParser.parse(null), isNull);
    });

    test('empty → null', () {
      expect(TimeParser.parse(''), isNull);
    });

    test('midnight', () {
      final r = TimeParser.parse('00:00');
      expect(r, isNotNull);
      expect(r!.hour, 0);
      expect(r.minute, 0);
    });

    test('end of day', () {
      final r = TimeParser.parse('23:59');
      expect(r, isNotNull);
      expect(r!.hour, 23);
      expect(r.minute, 59);
    });

    test('typical time', () {
      final r = TimeParser.parse('20:30');
      expect(r, isNotNull);
      expect(r!.hour, 20);
      expect(r.minute, 30);
    });

    test('single-digit hour (not zero-padded)', () {
      final r = TimeParser.parse('8:05');
      expect(r, isNotNull);
      expect(r!.hour, 8);
      expect(r.minute, 5);
    });

    test('rejects out-of-range hour', () {
      expect(TimeParser.parse('24:00'), isNull);
      expect(TimeParser.parse('99:00'), isNull);
    });

    test('rejects out-of-range minute', () {
      expect(TimeParser.parse('12:60'), isNull);
      expect(TimeParser.parse('12:99'), isNull);
    });

    test('rejects negative', () {
      expect(TimeParser.parse('-1:00'), isNull);
      expect(TimeParser.parse('12:-5'), isNull);
    });

    test('rejects missing colon', () {
      expect(TimeParser.parse('1230'), isNull);
    });

    test('rejects too many parts', () {
      expect(TimeParser.parse('12:30:00'), isNull);
    });

    test('rejects non-numeric', () {
      expect(TimeParser.parse('ab:cd'), isNull);
      expect(TimeParser.parse('12:xx'), isNull);
    });

    test('rejects empty parts', () {
      expect(TimeParser.parse(':30'), isNull);
      expect(TimeParser.parse('12:'), isNull);
      expect(TimeParser.parse(':'), isNull);
    });
  });

  group('TimeParser.format', () {
    test('midnight', () => expect(TimeParser.format(0, 0), '00:00'));
    test('end of day', () => expect(TimeParser.format(23, 59), '23:59'));
    test('zero-pads hour', () => expect(TimeParser.format(5, 30), '05:30'));
    test('zero-pads minute', () => expect(TimeParser.format(20, 5), '20:05'));
    test('does not exceed two digits', () {
      expect(TimeParser.format(20, 30), '20:30');
    });
  });

  group('parse ↔ format roundtrip', () {
    test('produces identical strings', () {
      for (final s in ['00:00', '05:30', '12:45', '20:05', '23:59']) {
        final parsed = TimeParser.parse(s);
        expect(parsed, isNotNull, reason: 'parse failed for $s');
        final formatted = TimeParser.format(parsed!.hour, parsed.minute);
        expect(formatted, s, reason: 'roundtrip failed for $s');
      }
    });
  });

  group('TimeParser roundtrip', () {
    test('parse(format(h, m)) == (h, m) for all hours', () {
      for (var h = 0; h < 24; h++) {
        final s = TimeParser.format(h, 30);
        final r = TimeParser.parse(s);
        expect(r, isNotNull);
        expect(r!.hour, h);
        expect(r.minute, 30);
      }
    });

    test('format zero-pads correctly for all minute values', () {
      for (var m = 0; m < 60; m++) {
        final s = TimeParser.format(12, m);
        expect(s.length, 5);
        expect(s[2], ':');
      }
    });
  });
}
