import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/services/auth_service.dart';
import 'package:pixel_quest/services/firestore_service.dart';
import 'package:pixel_quest/services/notification_scheduler.dart';
import 'package:pixel_quest/viewmodels/home_view_model.dart';

// ── Firestore stub that can fail the streams on demand ───────────────────
class _ErrorOnDemandFirestore extends FirestoreService {
  _ErrorOnDemandFirestore(FirebaseFirestore db) : super.protected(db: db);

  bool failQuests = false;
  bool failProgress = false;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchQuests(String uid) {
    if (failQuests) {
      return Stream.error(Exception('simulated quests stream failure'));
    }
    return super.watchQuests(uid);
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProgress(String uid) {
    if (failProgress) {
      return Stream.error(Exception('simulated progress stream failure'));
    }
    return super.watchProgress(uid);
  }
}

// ── Fake notification scheduler ──────────────────────────────────────────
class _FakeNotifications implements NotificationScheduler {
  @override
  Future<void> scheduleQuestReminder(Quest quest) async {}
  @override
  Future<void> cancelQuestReminder(String questId) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> rescheduleAllForQuests(List<Quest> quests) async {}
}

// ── Test bootstrap helper ────────────────────────────────────────────────
//
// Returns the VM plus the actual uid the mock auth generated. Tests that
// write to Firestore directly must use `ctx.uid` — not a hard-coded 'u1' —
// because the uid comes from `createUserWithEmailAndPassword` and is not
// under our control.
typedef _Ctx = ({HomeViewModel vm, String uid, FakeFirebaseFirestore db});

Future<_Ctx> _bootstrappedVm({
  FakeFirebaseFirestore? db,
  MockFirebaseAuth? auth,
}) async {
  SharedPreferences.setMockInitialValues({});
  final firestore = db ?? FakeFirebaseFirestore();

  final mockAuth = auth ?? MockFirebaseAuth();
  if (mockAuth.currentUser == null) {
    await mockAuth.createUserWithEmailAndPassword(
      email: 'test@test.com',
      password: 'Test1234!',
    );
  }
  final uid = mockAuth.currentUser!.uid;

  final fs = FirestoreService.forTesting(firestore);
  final vm = HomeViewModel(
    auth: mockAuth,
    authService: AuthService.forTesting(auth: mockAuth, firestore: fs),
    firestore: fs,
    notifications: _FakeNotifications(),
  );
  await vm.bootstrap();

  return (vm: vm, uid: uid, db: firestore);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ══════════════════════════════════════════════════════════════════════
  // Bug 3: deleteQuest must work by id, not instance identity
  // ══════════════════════════════════════════════════════════════════════
  group('deleteQuest identity', () {
    test('removes the quest even when passed a copy', () async {
      final ctx = await _bootstrappedVm();
      final vm = ctx.vm;
      addTearDown(vm.dispose);

      final original = Quest(
        id: 'q1',
        title: 'A',
        category: QuestCategory.health,
        xp: 10,
      );
      await vm.addQuest(original);
      expect(vm.quests.length, 1);

      final copy = original.copyWith(title: 'A (edited)');
      expect(identical(copy, original), isFalse);

      await vm.deleteQuest(copy);

      expect(vm.quests, isEmpty);
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Bug 4: progress stream must recompute _availableXp on _xpSpent change
  // ══════════════════════════════════════════════════════════════════════
  group('progress stream recompute', () {
    test('external xpSpent write recomputes availableXp', () async {
      final ctx = await _bootstrappedVm();
      final vm = ctx.vm;
      addTearDown(vm.dispose);

      final quest = Quest(
        id: 'q1',
        title: 'A',
        category: QuestCategory.health,
        xp: 10,
      );
      await vm.addQuest(quest);
      await vm.toggleQuest(vm.quests.first);

      // Give the quest stream time to reflect the toggle.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(vm.availableXp, 10);

      // Simulate another device spending 5 XP via the progress doc.
      await ctx.db.collection('users').doc(ctx.uid).set({
        'xpSpent': 5,
      }, SetOptions(merge: true));

      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(vm.availableXp, 5); // FAILS today (stays 10)
    });
  });
  // ══════════════════════════════════════════════════════════════════════
  // 1C: stream error visibility + retry
  // ══════════════════════════════════════════════════════════════════════
  group('stream error handling', () {
    test('syncError is null immediately after successful bootstrap', () async {
      final db = FakeFirebaseFirestore();
      final fs = FirestoreService.forTesting(db);

      final ctx = await _bootstrappedVmWithFs(db: db, fs: fs);
      final vm = ctx.vm;
      addTearDown(vm.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(vm.syncError, isNull);
    });

    test('syncError is set when quests stream errors', () async {
      final db = FakeFirebaseFirestore();
      final fs = _ErrorOnDemandFirestore(db);
      fs.failQuests = true;

      final ctx = await _bootstrappedVmWithFs(db: db, fs: fs);
      final vm = ctx.vm;
      addTearDown(vm.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(vm.syncError, isNotNull);
      expect(vm.syncError, contains('quests'));
    });

    test('syncError is set when progress stream errors', () async {
      final db = FakeFirebaseFirestore();
      final fs = _ErrorOnDemandFirestore(db);
      fs.failProgress = true;

      final ctx = await _bootstrappedVmWithFs(db: db, fs: fs);
      final vm = ctx.vm;
      addTearDown(vm.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(vm.syncError, isNotNull);
      expect(vm.syncError, contains('progress'));
    });

    test('retrySync clears syncError and resubscribes successfully', () async {
      final db = FakeFirebaseFirestore();
      final fs = _ErrorOnDemandFirestore(db);
      fs.failQuests = true;

      final ctx = await _bootstrappedVmWithFs(db: db, fs: fs);
      final vm = ctx.vm;
      addTearDown(vm.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(vm.syncError, isNotNull);

      // Recover the underlying stream and retry.
      fs.failQuests = false;
      await vm.retrySync();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(vm.syncError, isNull);
    });

    test('retrySync is a safe no-op before bootstrap', () async {
      final vm = HomeViewModel(
        auth: MockFirebaseAuth(),
        authService: AuthService.forTesting(
          auth: MockFirebaseAuth(),
          firestore: FirestoreService.forTesting(FakeFirebaseFirestore()),
        ),
        firestore: FirestoreService.forTesting(FakeFirebaseFirestore()),
        notifications: _FakeNotifications(),
      );
      addTearDown(vm.dispose);

      await expectLater(vm.retrySync(), completes);
      expect(vm.syncError, isNull);
    });

    test('retrySync is a safe no-op after dispose', () async {
      final db = FakeFirebaseFirestore();
      final fs = FirestoreService.forTesting(db);

      final ctx = await _bootstrappedVmWithFs(db: db, fs: fs);
      final vm = ctx.vm;

      vm.dispose();
      await expectLater(vm.retrySync(), completes);
    });

    test('logout clears syncError', () async {
      final db = FakeFirebaseFirestore();
      final fs = _ErrorOnDemandFirestore(db);
      fs.failQuests = true;

      final ctx = await _bootstrappedVmWithFs(db: db, fs: fs);
      final vm = ctx.vm;
      addTearDown(vm.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(vm.syncError, isNotNull);

      await vm.logout();
      expect(vm.syncError, isNull);
    });

    test('concurrent retrySync calls do not corrupt error state', () async {
      final db = FakeFirebaseFirestore();
      final fs = _ErrorOnDemandFirestore(db);
      fs.failQuests = true;

      final ctx = await _bootstrappedVmWithFs(db: db, fs: fs);
      final vm = ctx.vm;
      addTearDown(vm.dispose);

      // Wait for the stream error to propagate.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(vm.syncError, isNotNull);

      // Recover the underlying stream, then fire three retries simultaneously.
      fs.failQuests = false;
      await Future.wait([vm.retrySync(), vm.retrySync(), vm.retrySync()]);

      // Give the re-subscribed streams a moment to deliver their first event.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Without the _retrying guard, one of the concurrent calls would cancel
      // a stream that the other had just started. That stream's onError would
      // fire late and overwrite the cleared state, leaving syncError non-null
      // even though the working subscription is delivering events fine.
      expect(vm.syncError, isNull);
    });
  });
}

// ── Variant of _bootstrappedVm that accepts a custom FirestoreService ───
// Needed when tests inject _ErrorOnDemandFirestore instead of the default.
typedef _Ctx2 = ({HomeViewModel vm, String uid});

Future<_Ctx2> _bootstrappedVmWithFs({
  required FakeFirebaseFirestore db,
  required FirestoreService fs,
}) async {
  SharedPreferences.setMockInitialValues({});
  final mockAuth = MockFirebaseAuth();
  await mockAuth.createUserWithEmailAndPassword(
    email: 'test@test.com',
    password: 'Test1234!',
  );
  final uid = mockAuth.currentUser!.uid;

  final vm = HomeViewModel(
    auth: mockAuth,
    authService: AuthService.forTesting(auth: mockAuth, firestore: fs),
    firestore: fs,
    notifications: _FakeNotifications(),
  );
  await vm.bootstrap();

  return (vm: vm, uid: uid);
}
