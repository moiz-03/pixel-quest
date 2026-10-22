import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/utils/date_helper.dart';

void main() {
  group('Quest.fromMap', () {
    test('parses a complete Firestore-shaped map', () {
      final m = {
        'title': 'Read a Book',
        'category': 'selfImprovement',
        'xp': 25,
        'completedDates': ['2026-10-13'],
        'reminderTime': '20:30',
      };

      final q = Quest.fromMap('abc', m);

      expect(q.id, 'abc');
      expect(q.title, 'Read a Book');
      expect(q.category, QuestCategory.selfImprovement);
      expect(q.xp, 25);
      expect(q.completedDates, ['2026-10-13']);
      expect(q.reminderTime, '20:30');
    });

    test('reminderTime is preserved when present', () {
      final q = Quest.fromMap('1', {'reminderTime': '08:00'});
      expect(q.reminderTime, '08:00');
    });

    test('reminderTime is null when missing', () {
      final q = Quest.fromMap('1', {'title': 'No reminder'});
      expect(q.reminderTime, isNull);
    });

    test('reminderTime is null when explicitly null', () {
      final q = Quest.fromMap('1', {'reminderTime': null});
      expect(q.reminderTime, isNull);
    });

    test('falls back to health for unknown category', () {
      final q = Quest.fromMap('1', {'category': 'nonsense'});
      expect(q.category, QuestCategory.health);
    });

    test('falls back to health for missing category', () {
      final q = Quest.fromMap('1', {});
      expect(q.category, QuestCategory.health);
    });

    test('uses default xp when missing', () {
      final q = Quest.fromMap('1', {});
      expect(q.xp, 10);
    });

    test('empty id parameter falls back to map id', () {
      final q = Quest.fromMap('', {'id': 'from-map'});
      expect(q.id, 'from-map');
    });

    test('explicit id parameter wins over map id', () {
      final q = Quest.fromMap('explicit', {'id': 'from-map'});
      expect(q.id, 'explicit');
    });

    test('handles num→int coercion for xp', () {
      final q = Quest.fromMap('1', {'xp': 25.0});
      expect(q.xp, 25);
    });

    test('handles string xp gracefully (falls back to default)', () {
      final q = Quest.fromMap('1', {'xp': 'not-a-number'});
      expect(q.xp, 10);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // completedDates
  // ══════════════════════════════════════════════════════════════════════════
  group('Quest.completedDates', () {
    test('constructor defaults to empty list', () {
      final q = Quest(
        id: '1',
        title: 'x',
        category: QuestCategory.health,
        xp: 10,
      );
      expect(q.completedDates, isEmpty);
    });

    test('constructor accepts a pre-populated list', () {
      final q = Quest(
        id: '1',
        title: 'x',
        category: QuestCategory.health,
        xp: 10,
        completedDates: ['2026-10-13'],
      );
      expect(q.completedDates, ['2026-10-13']);
    });

    test('completed getter is false when today is not in the list', () {
      final q = Quest(
        id: '1',
        title: 'x',
        category: QuestCategory.health,
        xp: 10,
        completedDates: ['2000-01-01'],
      );
      expect(q.completed, isFalse);
    });

    test('completed getter is true when today is in the list', () {
      final today = DateHelper.todayIso();
      final q = Quest(
        id: '1',
        title: 'x',
        category: QuestCategory.health,
        xp: 10,
        completedDates: [today],
      );
      expect(q.completed, isTrue);
    });

    test('completed getter is false on empty list', () {
      final q = Quest(
        id: '1',
        title: 'x',
        category: QuestCategory.health,
        xp: 10,
      );
      expect(q.completed, isFalse);
    });

    test('fromMap parses completedDates when present', () {
      final q = Quest.fromMap('1', {
        'completedDates': ['2026-10-01', '2026-10-02'],
      });
      expect(q.completedDates, ['2026-10-01', '2026-10-02']);
    });

    test('fromMap defaults to empty list when missing', () {
      final q = Quest.fromMap('1', {'title': 'no dates'});
      expect(q.completedDates, isEmpty);
    });

    test('fromMap migrates legacy completed:true → today', () {
      final q = Quest.fromMap('1', {'completed': true});
      expect(q.completedDates, [DateHelper.todayIso()]);
    });

    test('fromMap migrates legacy completed:false → empty', () {
      final q = Quest.fromMap('1', {'completed': false});
      expect(q.completedDates, isEmpty);
    });

    test('fromMap prefers completedDates over legacy completed', () {
      final q = Quest.fromMap('1', {
        'completed': true,
        'completedDates': ['2026-01-01'],
      });
      expect(q.completedDates, ['2026-01-01']);
    });

    test('fromMap filters out non-string entries in completedDates', () {
      final q = Quest.fromMap('1', {
        'completedDates': ['2026-10-01', 42, null, '2026-10-02'],
      });
      expect(q.completedDates, ['2026-10-01', '2026-10-02']);
    });

    test('fromMap handles completedDates that is not a list', () {
      final q = Quest.fromMap('1', {'completedDates': 'not-a-list'});
      // Falls back to legacy `completed` (missing here → false → empty)
      expect(q.completedDates, isEmpty);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // toMap
  // ══════════════════════════════════════════════════════════════════════════
  group('Quest.toMap', () {
    test('produces a map with all fields', () {
      final q = Quest(
        id: 'abc',
        title: 'Read',
        category: QuestCategory.health,
        xp: 15,
        completedDates: ['2026-10-13'],
        reminderTime: '20:00',
      );

      final m = q.toMap();

      expect(m['id'], 'abc');
      expect(m['title'], 'Read');
      expect(m['category'], 'health');
      expect(m['xp'], 15);
      expect(m['completedDates'], ['2026-10-13']);
      expect(m['reminderTime'], '20:00');
    });

    test('toMap writes category as name string', () {
      final q = Quest(
        id: '1',
        title: 'x',
        category: QuestCategory.skills,
        xp: 10,
      );
      expect(q.toMap()['category'], 'skills');
    });

    test('toMap writes empty list when never completed', () {
      final q = Quest(
        id: '1',
        title: 'x',
        category: QuestCategory.health,
        xp: 10,
      );
      expect(q.toMap()['completedDates'], <String>[]);
    });

    test('toMap writes null reminderTime when unset', () {
      final q = Quest(
        id: '1',
        title: 'x',
        category: QuestCategory.health,
        xp: 10,
      );
      expect(q.toMap()['reminderTime'], isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Round-trip
  // ══════════════════════════════════════════════════════════════════════════
  group('Quest round-trip through map', () {
    test('preserves all fields', () {
      final original = Quest(
        id: '1',
        title: 'Read',
        category: QuestCategory.selfImprovement,
        xp: 25,
        completedDates: ['2026-10-10', '2026-10-11', '2026-10-12'],
        reminderTime: '08:30',
      );

      final restored = Quest.fromMap('', original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.category, original.category);
      expect(restored.xp, original.xp);
      expect(restored.completedDates, original.completedDates);
      expect(restored.reminderTime, original.reminderTime);
    });

    test('roundtrip preserves empty completedDates', () {
      final original = Quest(
        id: '1',
        title: 'Read',
        category: QuestCategory.health,
        xp: 10,
      );

      final restored = Quest.fromMap('', original.toMap());
      expect(restored.completedDates, isEmpty);
    });

    test('roundtrip preserves null reminderTime', () {
      final original = Quest(
        id: '1',
        title: 'Read',
        category: QuestCategory.health,
        xp: 10,
      );

      final restored = Quest.fromMap('', original.toMap());
      expect(restored.reminderTime, isNull);
    });

    test('every field survives for every category', () {
      for (final cat in QuestCategory.values) {
        final original = Quest(
          id: 'id-${cat.name}',
          title: 'Title ${cat.displayName}',
          category: cat,
          xp: 42,
          completedDates: ['2026-10-13'],
          reminderTime: '12:34',
        );
        final restored = Quest.fromMap('', original.toMap());
        expect(restored.category, cat);
        expect(restored.xp, 42);
        expect(restored.completedDates, ['2026-10-13']);
        expect(restored.reminderTime, '12:34');
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Legacy migration
  // ══════════════════════════════════════════════════════════════════════════
  group('Quest legacy migration', () {
    test('old payload with completed:true becomes today', () {
      // Simulates data written before the refactor
      final legacy = {
        'id': '1',
        'title': 'Old Quest',
        'category': 'health',
        'xp': 15,
        'completed': true,
      };
      final q = Quest.fromMap('1', legacy);
      expect(q.completed, isTrue);
      expect(q.completedDates.length, 1);
      expect(q.completedDates.first, DateHelper.todayIso());
    });

    test('old payload with completed:false becomes empty', () {
      final legacy = {
        'id': '1',
        'title': 'Old Quest',
        'category': 'health',
        'xp': 15,
        'completed': false,
      };
      final q = Quest.fromMap('1', legacy);
      expect(q.completed, isFalse);
      expect(q.completedDates, isEmpty);
    });
  });
}
