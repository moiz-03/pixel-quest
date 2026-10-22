import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/utils/date_helper.dart';

void main() {
  Quest build({String? reminderTime, bool completed = false}) => Quest(
    id: '1',
    title: 'Read a Book',
    category: QuestCategory.health,
    xp: 15,
    completedDates: completed ? [DateHelper.todayIso()] : [],
    reminderTime: reminderTime,
  );

  group('Quest model', () {
    test('reminderTime defaults to null', () {
      final q = build();
      expect(q.reminderTime, isNull);
    });

    test('reminderTime accepts a value', () {
      final q = build(reminderTime: '08:30');
      expect(q.reminderTime, '08:30');
    });

    test('reminderTime is mutable', () {
      final q = build();
      q.reminderTime = '21:00';
      expect(q.reminderTime, '21:00');
    });

    test('reminderTime can be cleared to null', () {
      final q = build(reminderTime: '08:30');
      q.reminderTime = null;
      expect(q.reminderTime, isNull);
    });

    test('completed defaults to false', () {
      final q = build();
      expect(q.completed, isFalse);
    });

    test('id is final', () {
      final q = build();
      expect(q.id, '1');
    });
  });

  group('QuestCategory metadata', () {
    test('every category has a non-empty label', () {
      for (final c in QuestCategory.values) {
        expect(c.label, isNotEmpty);
      }
    });

    test('labels are unique', () {
      final labels = QuestCategory.values.map((c) => c.label).toSet();
      expect(labels.length, QuestCategory.values.length);
    });
  });
}
