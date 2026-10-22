import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `NotificationService.protected()` uses FirebaseFirestore.instance by
  // default, which requires Firebase.initializeApp(). Pass a fake to keep
  // this test hermetic. The FlutterLocalNotificationsPlugin inside the
  // service still can't initialize (no platform channel in the test VM),
  // so every notification call fails — which is exactly the failure mode
  // the resilience fix targets.
  NotificationService newService() =>
      NotificationService.protected(db: FakeFirebaseFirestore());

  group('rescheduleAllForQuests — resilience', () {
    test('does not throw even when plugin is unavailable', () async {
      final svc = newService();
      final quests = [
        Quest(
          id: 'q1',
          title: 'A',
          category: QuestCategory.health,
          xp: 10,
          reminderTime: '08:00',
        ),
        Quest(
          id: 'q2',
          title: 'B',
          category: QuestCategory.health,
          xp: 10,
          reminderTime: '09:00',
        ),
        Quest(
          id: 'q3',
          title: 'C',
          category: QuestCategory.health,
          xp: 10,
          reminderTime: '10:00',
        ),
      ];

      await expectLater(svc.rescheduleAllForQuests(quests), completes);
    });

    test('does not throw for a quest with malformed reminderTime', () async {
      final svc = newService();
      final quests = [
        Quest(
          id: 'q1',
          title: 'Bad',
          category: QuestCategory.health,
          xp: 10,
          reminderTime: 'not-a-time',
        ),
      ];

      await expectLater(svc.rescheduleAllForQuests(quests), completes);
    });

    test('does not throw for an empty quest list', () async {
      final svc = newService();
      await expectLater(svc.rescheduleAllForQuests([]), completes);
    });

    test(
      'scheduleQuestReminder does not throw when plugin unavailable',
      () async {
        final svc = newService();
        final quest = Quest(
          id: 'q1',
          title: 'A',
          category: QuestCategory.health,
          xp: 10,
          reminderTime: '08:00',
        );

        await expectLater(svc.scheduleQuestReminder(quest), completes);
      },
    );

    test(
      'cancelQuestReminder does not throw when plugin unavailable',
      () async {
        final svc = newService();
        await expectLater(svc.cancelQuestReminder('q1'), completes);
      },
    );

    test('cancelAll does not throw when plugin unavailable', () async {
      final svc = newService();
      await expectLater(svc.cancelAll(), completes);
    });
  });
}
