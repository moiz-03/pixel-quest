import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';

void main() {
  group('QuestCategory metadata', () {
    test('every category has a non-empty label', () {
      for (final c in QuestCategory.values) {
        expect(c.label, isNotEmpty);
      }
    });

    test('every category has a non-empty displayName', () {
      for (final c in QuestCategory.values) {
        expect(c.displayName, isNotEmpty);
      }
    });

    test('labels are uppercase', () {
      for (final c in QuestCategory.values) {
        expect(c.label, c.label.toUpperCase());
      }
    });

    test('labels are unique', () {
      final labels = QuestCategory.values.map((c) => c.label).toSet();
      expect(labels.length, QuestCategory.values.length);
    });

    test('displayNames are unique', () {
      final names = QuestCategory.values.map((c) => c.displayName).toSet();
      expect(names.length, QuestCategory.values.length);
    });
  });

  group('Quest model', () {
    test('defaults completed to false', () {
      final q = Quest(
        id: '1',
        title: 'test',
        category: QuestCategory.health,
        xp: 10,
      );
      expect(q.completed, isFalse);
    });

    test('title / category / xp are mutable', () {
      final q = Quest(
        id: '1',
        title: 'a',
        category: QuestCategory.health,
        xp: 10,
      );
      q.title = 'b';
      q.category = QuestCategory.fitness;
      q.xp = 50;
      expect(q.title, 'b');
      expect(q.category, QuestCategory.fitness);
      expect(q.xp, 50);
    });

    test('id is final (cannot reassign)', () {
      // This is a compile-time guarantee, but we assert the field is used.
      final q = Quest(
        id: 'fixed',
        title: 'a',
        category: QuestCategory.health,
        xp: 10,
      );
      expect(q.id, 'fixed');
    });
  });
}
