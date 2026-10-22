import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/services/firestore_service.dart';

Quest _quest(String id) =>
    Quest(id: id, title: 'Quest $id', category: QuestCategory.health, xp: 10);

void main() {
  late FakeFirebaseFirestore fakeDb;
  late FirestoreService service;

  setUp(() {
    fakeDb = FakeFirebaseFirestore();
    service = FirestoreService.forTesting(fakeDb);
  });

  group('replaceAllQuestsAndProgress', () {
    test('small account runs in a single batch', () async {
      final quests = List.generate(10, (i) => _quest('q$i'));

      await service.replaceAllQuestsAndProgress(
        'u1',
        quests,
        level: 1,
        currentXp: 0,
        xpToNext: 150,
        totalXp: 100,
        streak: 1,
      );

      final snap = await fakeDb
          .collection('users')
          .doc('u1')
          .collection('quests')
          .get();
      expect(snap.docs.length, 10);

      final userDoc = await fakeDb.collection('users').doc('u1').get();
      expect(userDoc.data()?['totalXp'], 100);
    });

    test('replaces existing quests (no duplicates)', () async {
      // Seed with 5 quests.
      for (var i = 0; i < 5; i++) {
        await fakeDb
            .collection('users')
            .doc('u1')
            .collection('quests')
            .doc('old$i')
            .set({'title': 'old'});
      }

      await service.replaceAllQuestsAndProgress(
        'u1',
        [_quest('new1'), _quest('new2')],
        level: 0,
        currentXp: 0,
        xpToNext: 100,
        totalXp: 0,
        streak: 0,
      );

      final snap = await fakeDb
          .collection('users')
          .doc('u1')
          .collection('quests')
          .get();
      expect(snap.docs.length, 2);
      expect(snap.docs.map((d) => d.id).toSet(), {'new1', 'new2'});
    });

    test('600 ops uses the chunked path and completes', () async {
      // 250 existing + 350 new + 1 user doc = 601 ops, exceeds 500.
      for (var i = 0; i < 250; i++) {
        await fakeDb
            .collection('users')
            .doc('u1')
            .collection('quests')
            .doc('old$i')
            .set({'title': 'old'});
      }

      final newQuests = List.generate(350, (i) => _quest('new$i'));

      await service.replaceAllQuestsAndProgress(
        'u1',
        newQuests,
        level: 3,
        currentXp: 25,
        xpToNext: 250,
        totalXp: 475,
        streak: 5,
      );

      final snap = await fakeDb
          .collection('users')
          .doc('u1')
          .collection('quests')
          .get();
      expect(snap.docs.length, 350);
      expect(snap.docs.every((d) => d.id.startsWith('new')), isTrue);

      final userDoc = await fakeDb.collection('users').doc('u1').get();
      expect(userDoc.data()?['totalXp'], 475);
      expect(userDoc.data()?['streak'], 5);
    });

    test('exactly 500 ops uses the single-batch path', () async {
      // 499 quests + 1 user doc = 500 ops.
      final quests = List.generate(499, (i) => _quest('q$i'));

      await service.replaceAllQuestsAndProgress(
        'u1',
        quests,
        level: 0,
        currentXp: 0,
        xpToNext: 100,
        totalXp: 0,
        streak: 0,
      );

      final snap = await fakeDb
          .collection('users')
          .doc('u1')
          .collection('quests')
          .get();
      expect(snap.docs.length, 499);
    });
  });
}
