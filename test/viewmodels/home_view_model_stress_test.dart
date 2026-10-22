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

Quest _quest(String id) =>
    Quest(id: id, title: 'Quest $id', category: QuestCategory.health, xp: 10);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bootstrap with 500 cached quests completes in under 5s', () async {
    SharedPreferences.setMockInitialValues({});

    const uid = 'stress-user';
    final quests = List.generate(500, (i) => _quest('q$i'));
    await Prefs.saveQuests(uid, quests);

    final mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: uid, email: 'stress@example.com'),
    );
    final fakeDb = FakeFirebaseFirestore();
    final firestoreService = FirestoreService.forTesting(fakeDb);
    final authService = AuthService.forTesting(
      auth: mockAuth,
      firestore: firestoreService,
    );

    final vm = HomeViewModel(
      auth: mockAuth,
      authService: authService,
      firestore: firestoreService,
      notifications: _FakeNotificationScheduler(),
    );
    addTearDown(vm.dispose);

    final sw = Stopwatch()..start();
    final result = await vm.bootstrap();
    sw.stop();

    expect(result, isTrue);
    expect(vm.loaded, isTrue);
    expect(vm.quests.length, 500);
    expect(
      sw.elapsedMilliseconds,
      lessThan(5000),
      reason: 'bootstrap took ${sw.elapsedMilliseconds}ms',
    );

    // Verify the migration path ran (local → cloud) without choking.
    final remoteSnap = await fakeDb
        .collection('users')
        .doc(uid)
        .collection('quests')
        .get();
    expect(remoteSnap.docs.length, 500);
  });

  test('addQuest into a 500-quest list stays responsive', () async {
    SharedPreferences.setMockInitialValues({});

    const uid = 'stress-user-2';
    final initial = List.generate(500, (i) => _quest('q$i'));
    await Prefs.saveQuests(uid, initial);

    final mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: uid, email: 'stress2@example.com'),
    );
    final fakeDb = FakeFirebaseFirestore();
    final firestoreService = FirestoreService.forTesting(fakeDb);
    final authService = AuthService.forTesting(
      auth: mockAuth,
      firestore: firestoreService,
    );

    final vm = HomeViewModel(
      auth: mockAuth,
      authService: authService,
      firestore: firestoreService,
      notifications: _FakeNotificationScheduler(),
    );
    addTearDown(vm.dispose);

    await vm.bootstrap();

    final sw = Stopwatch()..start();
    await vm.addQuest(_quest('q500'));
    sw.stop();

    expect(vm.quests.length, 501);
    expect(
      sw.elapsedMilliseconds,
      lessThan(2000),
      reason: 'addQuest took ${sw.elapsedMilliseconds}ms',
    );
  });
}
