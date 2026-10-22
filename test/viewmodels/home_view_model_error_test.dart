import 'package:cloud_firestore/cloud_firestore.dart' show Source;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/services/auth_service.dart';
import 'package:pixel_quest/services/firestore_service.dart';
import 'package:pixel_quest/services/notification_scheduler.dart';
import 'package:pixel_quest/services/prefs.dart';
import 'package:pixel_quest/viewmodels/home_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> scheduleQuestReminder(Quest quest) async {}
  @override
  Future<void> cancelQuestReminder(String questId) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> rescheduleAllForQuests(List<Quest> quests) async {}
}

/// Subclass of [FirestoreService] that fails on specific methods.
/// Everything else delegates to the in-memory fake.
class _FailingFirestore extends FirestoreService {
  _FailingFirestore({
    required this.failLoadAll,
    required this.failSaveProgress,
    required this.failUpsertQuest,
  }) : super.protected(db: FakeFirebaseFirestore());

  final bool failLoadAll;
  final bool failSaveProgress;
  final bool failUpsertQuest;

  @override
  Future<({List<Quest> quests, Map<String, dynamic>? progress})> loadAll(
    String uid, {
    Source source = Source.serverAndCache,
  }) {
    if (failLoadAll) {
      throw Exception('simulated loadAll failure');
    }
    return super.loadAll(uid, source: source);
  }

  @override
  Future<void> saveProgress(
    String uid, {
    required int level,
    required int currentXp,
    required int xpToNext,
    required int totalXp,
    required int streak,
    int xpSpent = 0,
    int streakFreezes = 0,
    String? lastActive,
    List<String>? streakHistory,
  }) {
    if (failSaveProgress) {
      throw Exception('simulated saveProgress failure');
    }
    return super.saveProgress(
      uid,
      level: level,
      currentXp: currentXp,
      xpToNext: xpToNext,
      totalXp: totalXp,
      streak: streak,
      xpSpent: xpSpent,
      streakFreezes: streakFreezes,
      lastActive: lastActive,
      streakHistory: streakHistory,
    );
  }

  @override
  Future<void> upsertQuest(String uid, Quest quest) {
    if (failUpsertQuest) {
      throw Exception('simulated upsertQuest failure');
    }
    return super.upsertQuest(uid, quest);
  }
}

Quest _quest(String id, {int xp = 10}) =>
    Quest(id: id, title: 'Test quest', category: QuestCategory.health, xp: xp);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: 'u1',
        email: 'test@example.com',
        displayName: 'Tester',
      ),
    );
  });

  HomeViewModel makeVm(FirestoreService firestore) {
    authService = AuthService.forTesting(auth: mockAuth, firestore: firestore);
    return HomeViewModel(
      auth: mockAuth,
      authService: authService,
      firestore: firestore,
      notifications: _FakeNotificationScheduler(),
    );
  }

  group('bootstrap error paths', () {
    test('falls back to cache when loadAll throws', () async {
      // Seed Prefs with a quest and a bit of progress.
      await Prefs.saveQuests('u1', [_quest('q1', xp: 20)]);

      final vm = makeVm(
        _FailingFirestore(
          failLoadAll: true,
          failSaveProgress: false,
          failUpsertQuest: false,
        ),
      );
      addTearDown(vm.dispose);

      final result = await vm.bootstrap();

      // Bootstrap should still succeed — it caught the exception and
      // used the local cache.
      expect(result, isTrue);
      expect(vm.loaded, isTrue);
      expect(vm.quests.length, 1);
      expect(vm.quests.first.id, 'q1');
    });

    test('marks loaded even when both cache and remote are empty', () async {
      final vm = makeVm(
        _FailingFirestore(
          failLoadAll: false,
          failSaveProgress: false,
          failUpsertQuest: false,
        ),
      );
      addTearDown(vm.dispose);

      final result = await vm.bootstrap();

      expect(result, isTrue);
      expect(vm.loaded, isTrue);
      expect(vm.quests, isEmpty);
    });
  });

  group('persist error paths', () {
    test('toggleQuest survives Firestore saveProgress failure', () async {
      final vm = makeVm(
        _FailingFirestore(
          failLoadAll: false,
          failSaveProgress: true,
          failUpsertQuest: false,
        ),
      );
      addTearDown(vm.dispose);

      await vm.bootstrap();

      final q = _quest('q1', xp: 20);
      await vm.addQuest(q);

      // After addQuest, the realtime stream may have replaced our local q
      // with a fresh copy from Firestore. Always toggle the live instance.
      final live = vm.quests.firstWhere((x) => x.id == 'q1');
      await vm.toggleQuest(live);

      // In-memory state is correct despite Firestore rejecting the write.
      expect(live.completed, isTrue);
      expect(vm.availableXp, 20);
      expect(vm.streak, 1);
    });

    test('addQuest does not throw when Firestore upsertQuest fails', () async {
      final vm = makeVm(
        _FailingFirestore(
          failLoadAll: false,
          failSaveProgress: false,
          failUpsertQuest: true,
        ),
      );
      addTearDown(vm.dispose);

      await vm.bootstrap();

      // The VM catches the Firestore exception internally. From the
      // caller's perspective, addQuest must complete normally.
      await expectLater(vm.addQuest(_quest('q1')), completes);
    });

    test('deleteQuest does not throw when Firestore write fails', () async {
      final vm = makeVm(
        _FailingFirestore(
          failLoadAll: false,
          failSaveProgress: false,
          failUpsertQuest: true,
        ),
      );
      addTearDown(vm.dispose);

      await vm.bootstrap();

      final q = _quest('q1');
      await vm.addQuest(q);

      await expectLater(vm.deleteQuest(q), completes);
    });
  });
}
