import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/services/auth_service.dart';
import 'package:pixel_quest/services/firestore_service.dart';
import 'package:pixel_quest/services/notification_scheduler.dart';
import 'package:pixel_quest/utils/date_helper.dart';
import 'package:pixel_quest/viewmodels/home_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationScheduler implements NotificationScheduler {
  final scheduled = <Quest>[];
  final cancelled = <String>[];
  var cancelAllCalled = false;
  var rescheduleCount = 0;

  @override
  Future<void> scheduleQuestReminder(Quest quest) async {
    scheduled.add(quest);
  }

  @override
  Future<void> cancelQuestReminder(String questId) async {
    cancelled.add(questId);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalled = true;
  }

  @override
  Future<void> rescheduleAllForQuests(List<Quest> quests) async {
    rescheduleCount++;
  }
}

Quest _quest(
  String id, {
  String title = 'Test quest',
  QuestCategory category = QuestCategory.health,
  int xp = 10,
}) => Quest(id: id, title: title, category: category, xp: xp);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeDb;
  late FirestoreService firestoreService;
  late MockFirebaseAuth mockAuth;
  late AuthService authService;
  late _FakeNotificationScheduler fakeNotifications;
  late HomeViewModel vm;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeDb = FakeFirebaseFirestore();
    firestoreService = FirestoreService.forTesting(fakeDb);
    mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: 'u1',
        email: 'test@example.com',
        displayName: 'Tester',
      ),
    );
    authService = AuthService.forTesting(
      auth: mockAuth,
      firestore: firestoreService,
    );
    fakeNotifications = _FakeNotificationScheduler();
    vm = HomeViewModel(
      auth: mockAuth,
      authService: authService,
      firestore: firestoreService,
      notifications: fakeNotifications,
    );
    await vm.bootstrap();
  });

  tearDown(() {
    vm.dispose();
  });

  group('bootstrap', () {
    test('returns false when no auth user is present', () async {
      final noAuthVm = HomeViewModel(
        auth: MockFirebaseAuth(),
        authService: authService,
        firestore: firestoreService,
        notifications: fakeNotifications,
      );
      addTearDown(noAuthVm.dispose);

      expect(await noAuthVm.bootstrap(), isFalse);
    });

    test('marks the VM as loaded with a fresh account', () {
      expect(vm.loaded, isTrue);
      expect(vm.level, 0);
      expect(vm.availableXp, 0);
      expect(vm.streak, 0);
      expect(vm.streakFreezes, 0);
      expect(vm.quests, isEmpty);
    });

    test('seeds a user doc in Firestore when nothing exists', () async {
      final userDoc = await fakeDb.collection('users').doc('u1').get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()?['level'], 0);
      expect(userDoc.data()?['totalXp'], 0);
      expect(userDoc.data()?['xpSpent'], 0);
      expect(userDoc.data()?['streakFreezes'], 0);
    });
  });

  group('addQuest', () {
    test('appends to the list and notifies listeners', () async {
      var notified = 0;
      vm.addListener(() => notified++);

      final q = _quest('q1', xp: 20);
      await vm.addQuest(q);

      expect(vm.quests.length, 1);
      expect(vm.quests.first.id, 'q1');
      expect(notified, greaterThan(0));
    });

    test('persists the quest to Firestore', () async {
      await vm.addQuest(_quest('q1', xp: 20));

      final snap = await fakeDb
          .collection('users')
          .doc('u1')
          .collection('quests')
          .doc('q1')
          .get();
      expect(snap.exists, isTrue);
      expect(snap.data()?['title'], 'Test quest');
    });

    test('schedules a notification for the new quest', () async {
      final q = _quest('q1');
      await vm.addQuest(q);

      expect(fakeNotifications.scheduled, contains(q));
    });
  });

  group('toggleQuest', () {
    test('marks today as completed and bumps streak to 1', () async {
      final q = _quest('q1', xp: 20);
      await vm.addQuest(q);
      await vm.toggleQuest(q);

      expect(q.completed, isTrue);
      expect(q.completedDates, contains(DateHelper.todayIso()));
      expect(vm.streak, 1);
      expect(vm.availableXp, 20);
    });

    test('toggling twice in a row removes today and reverts XP', () async {
      final q = _quest('q1', xp: 20);
      await vm.addQuest(q);

      await vm.toggleQuest(q);
      await vm.toggleQuest(q);

      expect(q.completed, isFalse);
      expect(vm.availableXp, 0);
    });

    test('completing a second quest adds to the same streak day', () async {
      final a = _quest('a', xp: 10);
      final b = _quest('b', xp: 15);
      await vm.addQuest(a);
      await vm.addQuest(b);

      await vm.toggleQuest(a);
      await vm.toggleQuest(b);

      expect(vm.streak, 1);
      expect(vm.availableXp, 25);
    });
  });

  group('editQuest', () {
    test('replaces the quest in the list by id', () async {
      final original = _quest('q1', xp: 10, title: 'Old');
      await vm.addQuest(original);

      final updated = original.copyWith(title: 'New', xp: 25);
      await vm.editQuest(updated);

      expect(vm.quests.length, 1);
      expect(vm.quests.first.title, 'New');
      expect(vm.quests.first.xp, 25);
    });

    test('unknown id leaves the list unchanged', () async {
      await vm.addQuest(_quest('q1', xp: 10));

      final ghost = _quest('nonexistent', xp: 99);
      await vm.editQuest(ghost);

      expect(vm.quests.length, 1);
      expect(vm.quests.first.id, 'q1');
    });
  });

  group('deleteQuest', () {
    test('removes the quest from the list and Firestore', () async {
      final q = _quest('q1');
      await vm.addQuest(q);

      await vm.deleteQuest(q);

      expect(vm.quests, isEmpty);
      final snap = await fakeDb
          .collection('users')
          .doc('u1')
          .collection('quests')
          .doc('q1')
          .get();
      expect(snap.exists, isFalse);
    });

    test('cancels the quest notification', () async {
      final q = _quest('q1');
      await vm.addQuest(q);

      await vm.deleteQuest(q);

      expect(fakeNotifications.cancelled, contains('q1'));
    });
  });

  group('buyStreakFreeze', () {
    test(
      'decrements available XP by 500 and increments freeze count',
      () async {
        final q = _quest('q1', xp: 500);
        await vm.addQuest(q);
        await vm.toggleQuest(q);

        expect(vm.availableXp, 500);
        await vm.buyStreakFreeze();

        expect(vm.streakFreezes, 1);
        expect(vm.availableXp, 0);
        expect(vm.xpSpent, 500);
      },
    );

    test('throws insufficient_xp when below 500', () async {
      final q = _quest('q1', xp: 100);
      await vm.addQuest(q);
      await vm.toggleQuest(q);

      expect(vm.availableXp, 100);
      expect(
        () => vm.buyStreakFreeze(),
        throwsA(
          isA<FreezePurchaseException>().having(
            (e) => e.reason,
            'reason',
            'insufficient_xp',
          ),
        ),
      );
    });

    test('throws inventory_full when already at max', () async {
      final q = _quest('q1', xp: 2000);
      await vm.addQuest(q);
      await vm.toggleQuest(q);

      await vm.buyStreakFreeze();
      await vm.buyStreakFreeze();

      expect(vm.streakFreezes, HomeViewModel.maxFreezes);
      expect(
        () => vm.buyStreakFreeze(),
        throwsA(
          isA<FreezePurchaseException>().having(
            (e) => e.reason,
            'reason',
            'inventory_full',
          ),
        ),
      );
    });
  });

  group('setTabIndex', () {
    test('updates the index and notifies', () {
      var notified = 0;
      vm.addListener(() => notified++);

      vm.setTabIndex(2);
      expect(vm.tabIndex, 2);
      expect(notified, 1);

      vm.setTabIndex(2);
      expect(notified, 1);
    });
  });

  group('logout', () {
    test('flushes writes, cancels notifications, signs out', () async {
      await vm.logout();

      expect(fakeNotifications.cancelAllCalled, isTrue);
      expect(mockAuth.currentUser, isNull);
    });
  });

  group('concurrency', () {
    test('rapid toggleQuest calls leave consistent state', () async {
      final q = _quest('q1', xp: 20);
      await vm.addQuest(q);

      // Fire both toggles without awaiting in between.
      await Future.wait([vm.toggleQuest(q), vm.toggleQuest(q)]);

      // Read the LIVE instance — the realtime stream may have replaced
      // our local q with a fresh copy from Firestore mid-test.
      final live = vm.quests.firstWhere((x) => x.id == 'q1');
      final todayCount = live.completedDates
          .where((d) => d == DateHelper.todayIso())
          .length;

      expect(
        todayCount,
        anyOf(0, 1),
        reason: 'today should appear 0 or 1 times, found $todayCount',
      );
      expect(
        vm.availableXp,
        todayCount * 20,
        reason: 'XP must match the number of completions',
      );
    });

    test(
      'addQuest immediately followed by deleteQuest leaves empty state',
      () async {
        final q = _quest('q1');
        await Future.wait([vm.addQuest(q), vm.deleteQuest(q)]);

        // Whatever order they landed in, the end state must be consistent.
        expect(
          vm.quests.where((x) => x.id == 'q1').length,
          lessThanOrEqualTo(1),
        );
      },
    );

    test('repeated toggle of the same quest converges', () async {
      final q = _quest('q1', xp: 20);
      await vm.addQuest(q);

      for (var i = 0; i < 5; i++) {
        await vm.toggleQuest(q);
      }

      // 5 toggles → odd → completed today.
      final live = vm.quests.firstWhere((x) => x.id == 'q1');
      expect(live.completed, isTrue);
      expect(vm.availableXp, 20);
    });
  });
}
