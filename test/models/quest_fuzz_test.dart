import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';

/// Feeds random garbage into [Quest.fromMap] and asserts it never throws.
/// Catches crashes from corrupted Firestore documents — a real risk when
/// schemas evolve or a client version lags.
void main() {
  group('Quest.fromMap — fuzz', () {
    test('never throws on random map input', () {
      final rng = Random(42);
      for (var i = 0; i < 1000; i++) {
        final map = <String, dynamic>{
          'title': rng.nextBool() ? null : rng.nextInt(1 << 30).toString(),
          'xp': rng.nextBool() ? 'abc' : rng.nextInt(1 << 30),
          'completedDates': rng.nextBool()
              ? <Object?>[rng.nextInt(1 << 30), 'x', null, 42.5]
              : 'not-a-list',
          'category': rng.nextBool()
              ? 'invalid-category'
              : QuestCategory
                    .values[rng.nextInt(QuestCategory.values.length)]
                    .name,
          'reminderTime': rng.nextBool() ? null : rng.nextInt(1000).toString(),
        };

        expect(
          () => Quest.fromMap('id-$i', map),
          returnsNormally,
          reason: 'failed on iteration $i with map: $map',
        );
      }
    });

    test('never throws on empty maps', () {
      for (var i = 0; i < 100; i++) {
        expect(() => Quest.fromMap('id-$i', {}), returnsNormally);
      }
    });

    test('never throws on null id', () {
      expect(() => Quest.fromMap('', {}), returnsNormally);
    });

    test('never throws on deeply-nested garbage', () {
      final map = <String, dynamic>{
        'title': <String>[],
        'xp': <String, dynamic>{'nested': true},
        'completedDates': <Map<String, dynamic>>[
          {'nested': 'map'},
        ],
        'category': 42,
        'reminderTime': <String>[],
      };

      expect(() => Quest.fromMap('id', map), returnsNormally);
    });
  });
}
