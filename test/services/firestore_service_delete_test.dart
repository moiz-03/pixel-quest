import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pixel_quest/services/firestore_service.dart';

/// FakeFirebaseFirestore subclass that counts `batch()` calls, so we can
/// verify chunking. `fake_cloud_firestore` doesn't enforce the 500-write
/// limit, so this is the only way to prove chunking happened in tests.
class _CountingFakeFirestore extends FakeFirebaseFirestore {
  int batchCount = 0;

  @override
  WriteBatch batch() {
    batchCount++;
    return super.batch();
  }
}

const _uid = 'stress-user';

Future<void> _seedQuests(_CountingFakeFirestore db, int count) async {
  // Seed in chunks of 400. `fake_cloud_firestore` enforces the real
  // 500-write limit, so a single 501-write batch would throw.
  const chunkSize = 400;
  for (var i = 0; i < count; i += chunkSize) {
    final end = (i + chunkSize).clamp(0, count);
    final seed = db.batch();
    for (var j = i; j < end; j++) {
      seed.set(
        db.collection('users').doc(_uid).collection('quests').doc('q$j'),
        {'title': 'Quest $j', 'xp': 10},
      );
    }
    await seed.commit();
  }
  // Reset so tests only count batches created by deleteAllUserData itself.
  db.batchCount = 0;
}

void main() {
  group('deleteAllUserData — chunking', () {
    test('501 quests → 2 batches (400 + 101)', () async {
      final db = _CountingFakeFirestore();
      await _seedQuests(db, 501);

      final svc = FirestoreService.forTesting(db);
      final ok = await svc.deleteAllUserData(_uid);

      expect(ok, isTrue);
      expect(
        db.batchCount,
        2,
        reason:
            '501 quests must chunk into 2 batches of ≤400, not one '
            'oversized batch that Firestore would reject',
      );

      final remaining = await db
          .collection('users')
          .doc(_uid)
          .collection('quests')
          .get();
      expect(remaining.docs, isEmpty, reason: 'all quests must be deleted');
    });

    test('400 quests → exactly 1 batch (boundary)', () async {
      final db = _CountingFakeFirestore();
      await _seedQuests(db, 400);

      final svc = FirestoreService.forTesting(db);
      await svc.deleteAllUserData(_uid);

      expect(db.batchCount, 1, reason: '400 fits in one batch, no chunking');
    });

    test('0 quests → 0 batches (no wasted commit)', () async {
      final db = _CountingFakeFirestore();
      // No quests seeded. Only user doc + username check run.

      final svc = FirestoreService.forTesting(db);
      final ok = await svc.deleteAllUserData(_uid);

      expect(ok, isTrue);
      expect(db.batchCount, 0, reason: 'nothing to delete → no batch created');
    });
  });

  group('deleteAllUserData — data is actually gone', () {
    test('deletes user doc, quests, and username atomically-safe', () async {
      final db = _CountingFakeFirestore();
      await db.collection('users').doc(_uid).set({'level': 5, 'totalXp': 1234});
      await _seedQuests(db, 10);
      await db.collection('usernames').doc('stress').set({'uid': _uid});

      final svc = FirestoreService.forTesting(db);
      final ok = await svc.deleteAllUserData(_uid);

      expect(ok, isTrue);
      expect((await db.collection('users').doc(_uid).get()).exists, isFalse);
      expect(
        (await db.collection('users').doc(_uid).collection('quests').get())
            .docs,
        isEmpty,
      );
      expect(
        (await db.collection('usernames').doc('stress').get()).exists,
        isFalse,
      );
    });

    test('does not touch another user\'s data', () async {
      final db = _CountingFakeFirestore();
      await _seedQuests(db, 5);
      // Seed another user's data
      await db.collection('users').doc('other').set({'level': 3});
      await db
          .collection('users')
          .doc('other')
          .collection('quests')
          .doc('q0')
          .set({'title': 'theirs'});

      final svc = FirestoreService.forTesting(db);
      await svc.deleteAllUserData(_uid);

      expect((await db.collection('users').doc('other').get()).exists, isTrue);
      final otherQuests = await db
          .collection('users')
          .doc('other')
          .collection('quests')
          .get();
      expect(otherQuests.docs.length, 1);
    });
  });
}
