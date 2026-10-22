import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pixel_quest/services/notification_service.dart';
import 'package:pixel_quest/utils/date_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_quest/services/notification_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeDb;
  late NotificationService notificationService;

  // Mock the method channel used by flutter_local_notifications
  const MethodChannel channel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  final List<MethodCall> log = <MethodCall>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({'pq_user_id': 'test_uid'});

    fakeDb = FakeFirebaseFirestore();

    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });

    notificationService = NotificationService.protected(db: fakeDb);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Foreground Actions (handleAction)', () {
    test('mark_done updates Firestore correctly', () async {
      await fakeDb
          .collection('users')
          .doc('test_uid')
          .collection('quests')
          .doc('q1')
          .set({'title': 'Read a book', 'completedDates': []});

      await notificationService.handleAction(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: 'mark_done',
          payload: 'q1',
        ),
      );

      final doc = await fakeDb
          .collection('users')
          .doc('test_uid')
          .collection('quests')
          .doc('q1')
          .get();
      final dates = doc.data()!['completedDates'] as List;
      expect(dates.contains(DateHelper.todayIso()), isTrue);
    });

    test('mark_done is idempotent (ArrayUnion deduplicates)', () async {
      await fakeDb
          .collection('users')
          .doc('test_uid')
          .collection('quests')
          .doc('q1')
          .set({'title': 'Read a book', 'completedDates': []});

      // Tap twice
      for (var i = 0; i < 2; i++) {
        await notificationService.handleAction(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            actionId: 'mark_done',
            payload: 'q1',
          ),
        );
      }

      final doc = await fakeDb
          .collection('users')
          .doc('test_uid')
          .collection('quests')
          .doc('q1')
          .get();
      final dates = doc.data()!['completedDates'] as List;
      expect(dates.where((d) => d == DateHelper.todayIso()).length, 1);
    });

    test(
      'snooze completes without throwing even when plugin is unavailable',
      () async {
        // Seed the quest so the Firestore lookup succeeds
        await fakeDb
            .collection('users')
            .doc('test_uid')
            .collection('quests')
            .doc('q1')
            .set({'title': 'Read a book'});

        // In unit tests the plugin platform isn't registered, so
        // _scheduleSnooze logs a warning and returns early. What we verify
        // here is that handleAction itself doesn't throw.
        await expectLater(
          notificationService.handleAction(
            const NotificationResponse(
              notificationResponseType:
                  NotificationResponseType.selectedNotificationAction,
              actionId: 'snooze',
              payload: 'q1',
            ),
          ),
          completes,
        );
      },
    );

    test('ignores unknown actions', () async {
      await notificationService.handleAction(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: 'unknown_action',
          payload: 'q1',
        ),
      );
    });

    test('ignores null payload', () async {
      await notificationService.handleAction(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: 'mark_done',
          payload: null,
        ),
      );
    });

    test('ignores empty payload', () async {
      final svc = NotificationService.protected(db: FakeFirebaseFirestore());
      await expectLater(
        svc.handleAction(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            actionId: 'mark_done',
            payload: '',
          ),
        ),
        completes,
      );
    });

    test(
      'foreground snooze id is in the snooze ID space, not the daily space',
      () {
        // _scheduleSnooze must use snoozeNotificationIdFor, not
        // notificationIdFor. If it uses the daily ID, tapping Snooze
        // overwrites the daily reminder and the user loses it until the
        // next rescheduleAllForQuests (next app launch).
        expect(snoozeNotificationIdFor('q1'), isNot(notificationIdFor('q1')));
      },
    );
  });
}
