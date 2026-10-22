import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/utils/date_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/services/prefs.dart';

const _uidA = 'user-A';
const _uidB = 'user-B';

Quest _quest(
  String id, {
  String title = 'Test quest',
  QuestCategory cat = QuestCategory.health,
  int xp = 10,
  bool completed = false,
}) => Quest(
  id: id,
  title: title,
  category: cat,
  xp: xp,
  completedDates: completed ? [DateHelper.todayIso()] : [],
);

Future<void> _writeRaw(String key, String value) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(key, value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Session defaults', () {
    test('hasAccount defaults to false', () async {
      expect(await Prefs.hasAccount(), isFalse);
    });
    test('isLoggedIn defaults to false', () async {
      expect(await Prefs.isLoggedIn(), isFalse);
    });
    test('rememberMe defaults to true', () async {
      expect(await Prefs.rememberMe(), isTrue);
    });
    test('currentUid defaults to null', () async {
      expect(await Prefs.currentUid, isNull);
    });
    test('username defaults to null', () async {
      expect(await Prefs.username, isNull);
    });
    test('email defaults to null', () async {
      expect(await Prefs.email, isNull);
    });
  });

  group('saveSession / clearSession', () {
    test('saveSession persists all fields', () async {
      await Prefs.saveSession(uid: _uidA, email: 'a@b.co', username: 'alice');
      expect(await Prefs.currentUid, _uidA);
      expect(await Prefs.email, 'a@b.co');
      expect(await Prefs.username, 'alice');
      expect(await Prefs.hasAccount(), isTrue);
      expect(await Prefs.isLoggedIn(), isTrue);
      expect(await Prefs.rememberMe(), isTrue);
    });

    test('saveSession with rememberMe=false stores false', () async {
      await Prefs.saveSession(
        uid: _uidA,
        email: 'a@b.co',
        username: 'alice',
        rememberMe: false,
      );
      expect(await Prefs.rememberMe(), isFalse);
    });

    test(
      'saveSession with null username does not overwrite previous',
      () async {
        await Prefs.saveSession(uid: _uidA, email: 'a@b.co', username: 'alice');
        await Prefs.saveSession(uid: _uidA, email: 'a@b.co');
        expect(await Prefs.username, 'alice');
      },
    );

    test('clearSession clears session but keeps hasAccount', () async {
      await Prefs.saveSession(uid: _uidA, email: 'a@b.co', username: 'alice');
      await Prefs.clearSession();
      expect(await Prefs.currentUid, isNull);
      expect(await Prefs.email, isNull);
      expect(await Prefs.username, isNull);
      expect(await Prefs.isLoggedIn(), isFalse);
      expect(await Prefs.hasAccount(), isTrue);
    });

    test('clearSession keeps rememberMe setting', () async {
      await Prefs.saveSession(
        uid: _uidA,
        email: 'a@b.co',
        username: 'alice',
        rememberMe: true,
      );
      await Prefs.clearSession();
      expect(await Prefs.rememberMe(), isTrue);
    });
  });

  group('saveQuests / loadQuests', () {
    test('roundtrip preserves all fields', () async {
      final quests = [
        _quest(
          '1',
          title: 'Read',
          cat: QuestCategory.selfImprovement,
          xp: 25,
          completed: true,
        ),
        _quest(
          '2',
          title: 'Run',
          cat: QuestCategory.fitness,
          xp: 50,
          completed: false,
        ),
      ];
      await Prefs.saveQuests(_uidA, quests);
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.length, 2);
      expect(loaded[0].id, '1');
      expect(loaded[0].title, 'Read');
      expect(loaded[0].category, QuestCategory.selfImprovement);
      expect(loaded[0].xp, 25);
      expect(loaded[0].completed, isTrue);
      expect(loaded[1].id, '2');
      expect(loaded[1].category, QuestCategory.fitness);
    });

    test('no data → empty list', () async {
      expect(await Prefs.loadQuests(_uidA), isEmpty);
    });

    test('empty list → empty list on reload', () async {
      await Prefs.saveQuests(_uidA, []);
      expect(await Prefs.loadQuests(_uidA), isEmpty);
    });

    test('corrupt JSON → empty list (no crash)', () async {
      await _writeRaw('pq_quests_$_uidA', 'not valid json {{{');
      expect(await Prefs.loadQuests(_uidA), isEmpty);
    });

    test('JSON that is not a list → empty list', () async {
      await _writeRaw('pq_quests_$_uidA', '{"oops":true}');
      expect(await Prefs.loadQuests(_uidA), isEmpty);
    });

    test('unknown category falls back to health', () async {
      await _writeRaw(
        'pq_quests_$_uidA',
        '[{"id":"1","title":"x","category":"nonexistent","xp":10,"completed":false}]',
      );
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.length, 1);
      expect(loaded[0].category, QuestCategory.health);
    });

    test('missing fields use safe defaults', () async {
      await _writeRaw('pq_quests_$_uidA', '[{}]');
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.length, 1);
      expect(loaded[0].id, '');
      expect(loaded[0].title, '');
      expect(loaded[0].xp, 10);
      expect(loaded[0].completed, isFalse);
    });

    test('non-map list entries are ignored', () async {
      await _writeRaw(
        'pq_quests_$_uidA',
        '[1, "two", {"id":"3","title":"ok","category":"health","xp":5,"completed":false}]',
      );
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.length, 1);
      expect(loaded[0].id, '3');
    });

    test('per-user isolation — A does not see B', () async {
      await Prefs.saveQuests(_uidA, [_quest('1')]);
      await Prefs.saveQuests(_uidB, [_quest('2'), _quest('3')]);
      expect((await Prefs.loadQuests(_uidA)).length, 1);
      expect((await Prefs.loadQuests(_uidB)).length, 2);
    });
  });

  group('saveProgress / loadProgress', () {
    test('defaults when nothing saved', () async {
      final p = await Prefs.loadProgress(_uidA);
      expect(p.level, 0);
      expect(p.currentXp, 0);
      expect(p.xpToNext, 100);
      expect(p.totalXp, 0);
      expect(p.streak, 0);
      expect(p.xpSpent, 0);
      expect(p.streakFreezes, 0);
    });

    test('roundtrip', () async {
      await Prefs.saveProgress(
        _uidA,
        level: 5,
        currentXp: 60,
        xpToNext: 350,
        totalXp: 1750,
        streak: 12,
        xpSpent: 500,
        streakFreezes: 2,
      );
      final p = await Prefs.loadProgress(_uidA);
      expect(p.level, 5);
      expect(p.currentXp, 60);
      expect(p.xpToNext, 350);
      expect(p.totalXp, 1750);
      expect(p.streak, 12);
      expect(p.xpSpent, 500);
      expect(p.streakFreezes, 2);
    });

    test('per-user isolation', () async {
      await Prefs.saveProgress(
        _uidA,
        level: 1,
        currentXp: 0,
        xpToNext: 150,
        totalXp: 100,
        streak: 1,
        xpSpent: 0,
        streakFreezes: 0,
      );
      await Prefs.saveProgress(
        _uidB,
        level: 9,
        currentXp: 0,
        xpToNext: 550,
        totalXp: 9000,
        streak: 50,
        xpSpent: 500,
        streakFreezes: 1,
      );
      final a = await Prefs.loadProgress(_uidA);
      final b = await Prefs.loadProgress(_uidB);
      expect(a.level, 1);
      expect(a.xpSpent, 0);
      expect(a.streakFreezes, 0);
      expect(b.level, 9);
      expect(b.xpSpent, 500);
      expect(b.streakFreezes, 1);
    });
  });

  group('Streak storage', () {
    test('lastActiveDate default is null', () async {
      expect(await Prefs.lastActiveDate(_uidA), isNull);
    });

    test('setLastActiveDate / lastActiveDate roundtrip', () async {
      await Prefs.setLastActiveDate(_uidA, '2026-10-09');
      expect(await Prefs.lastActiveDate(_uidA), '2026-10-09');
    });

    test('streakHistory default is empty', () async {
      expect(await Prefs.streakHistory(_uidA), isEmpty);
    });

    test('setStreakHistory / streakHistory roundtrip', () async {
      await Prefs.setStreakHistory(_uidA, [
        '2026-10-01',
        '2026-10-02',
        '2026-10-03',
      ]);
      expect(await Prefs.streakHistory(_uidA), [
        '2026-10-01',
        '2026-10-02',
        '2026-10-03',
      ]);
    });

    test('corrupt streakHistory JSON → empty list', () async {
      await _writeRaw('pq_streak_history_$_uidA', 'not-json');
      expect(await Prefs.streakHistory(_uidA), isEmpty);
    });

    test('streakHistory that is not a list → empty list', () async {
      await _writeRaw('pq_streak_history_$_uidA', '{"a":1}');
      expect(await Prefs.streakHistory(_uidA), isEmpty);
    });

    test('per-user isolation', () async {
      await Prefs.setLastActiveDate(_uidA, '2026-10-09');
      expect(await Prefs.lastActiveDate(_uidB), isNull);
    });
  });

  group('clearProgress', () {
    test('wipes quests, progress, and streak for the given user', () async {
      await Prefs.saveQuests(_uidA, [_quest('1')]);
      await Prefs.saveProgress(
        _uidA,
        level: 5,
        currentXp: 60,
        xpToNext: 350,
        totalXp: 1750,
        streak: 12,
        xpSpent: 500,
        streakFreezes: 2,
      );
      await Prefs.setLastActiveDate(_uidA, '2026-10-09');
      await Prefs.setStreakHistory(_uidA, ['2026-10-09']);

      await Prefs.clearProgress(_uidA);

      expect(await Prefs.loadQuests(_uidA), isEmpty);
      final p = await Prefs.loadProgress(_uidA);
      expect(p.level, 0);
      expect(p.totalXp, 0);
      expect(p.streak, 0);
      expect(p.xpSpent, 0);
      expect(p.streakFreezes, 0);
      expect(await Prefs.lastActiveDate(_uidA), isNull);
      expect(await Prefs.streakHistory(_uidA), isEmpty);
    });

    test('does NOT touch other users', () async {
      await Prefs.saveQuests(_uidA, [_quest('1')]);
      await Prefs.saveQuests(_uidB, [_quest('2')]);
      await Prefs.clearProgress(_uidA);
      expect((await Prefs.loadQuests(_uidB)).length, 1);
    });

    test('does NOT touch session', () async {
      await Prefs.saveSession(uid: _uidA, email: 'a@b.co', username: 'alice');
      await Prefs.clearProgress(_uidA);
      expect(await Prefs.currentUid, _uidA);
      expect(await Prefs.isLoggedIn(), isTrue);
    });
  });

  group('Quests — reminderTime roundtrip', () {
    test('preserves reminderTime through save/load', () async {
      final quests = [
        Quest(
          id: '1',
          title: 'Read',
          category: QuestCategory.selfImprovement,
          xp: 25,
          reminderTime: '08:30',
        ),
        Quest(
          id: '2',
          title: 'Run',
          category: QuestCategory.fitness,
          xp: 50,
          reminderTime: '18:00',
        ),
      ];
      await Prefs.saveQuests(_uidA, quests);
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.length, 2);
      expect(loaded[0].reminderTime, '08:30');
      expect(loaded[1].reminderTime, '18:00');
    });

    test('preserves null reminderTime', () async {
      final quests = [
        Quest(id: '1', title: 'Read', category: QuestCategory.health, xp: 10),
      ];
      await Prefs.saveQuests(_uidA, quests);
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.length, 1);
      expect(loaded[0].reminderTime, isNull);
    });

    test('missing reminderTime key → null on load', () async {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(
        'pq_quests_$_uidA',
        '[{"id":"1","title":"Old","category":"health","xp":10,"completed":false}]',
      );
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.length, 1);
      expect(loaded[0].reminderTime, isNull);
    });
  });

  group('Quests — reminderTime serialization', () {
    test('roundtrip preserves reminderTime', () async {
      final quests = [
        Quest(
          id: '1',
          title: 'Read',
          category: QuestCategory.selfImprovement,
          xp: 25,
          reminderTime: '08:30',
        ),
      ];
      await Prefs.saveQuests(_uidA, quests);
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.single.reminderTime, '08:30');
    });

    test('roundtrip preserves null reminderTime', () async {
      final quests = [
        Quest(id: '1', title: 'Read', category: QuestCategory.health, xp: 10),
      ];
      await Prefs.saveQuests(_uidA, quests);
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.single.reminderTime, isNull);
    });

    test('clearing reminderTime to null persists', () async {
      final quest = Quest(
        id: '1',
        title: 'Read',
        category: QuestCategory.health,
        xp: 10,
        reminderTime: '08:00',
      );
      await Prefs.saveQuests(_uidA, [quest]);

      quest.reminderTime = null;
      await Prefs.saveQuests(_uidA, [quest]);

      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.single.reminderTime, isNull);
    });

    test('legacy payload without reminderTime field parses', () async {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(
        'pq_quests_$_uidA',
        '[{"id":"1","title":"Old","category":"health","xp":10,"completed":false}]',
      );
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.single.reminderTime, isNull);
    });

    test('payload with reminderTime:null parses to null', () async {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(
        'pq_quests_$_uidA',
        '[{"id":"1","title":"Old","category":"health","xp":10,"completed":false,"reminderTime":null}]',
      );
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded.single.reminderTime, isNull);
    });

    test('multiple quests with mixed reminder states', () async {
      final quests = [
        Quest(
          id: '1',
          title: 'A',
          category: QuestCategory.health,
          xp: 10,
          reminderTime: '08:00',
        ),
        Quest(id: '2', title: 'B', category: QuestCategory.health, xp: 10),
        Quest(
          id: '3',
          title: 'C',
          category: QuestCategory.health,
          xp: 10,
          reminderTime: '20:30',
        ),
      ];
      await Prefs.saveQuests(_uidA, quests);
      final loaded = await Prefs.loadQuests(_uidA);
      expect(loaded[0].reminderTime, '08:00');
      expect(loaded[1].reminderTime, isNull);
      expect(loaded[2].reminderTime, '20:30');
    });
  });
}
