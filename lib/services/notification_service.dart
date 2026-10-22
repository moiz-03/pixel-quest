import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pixel_quest/services/notification_id.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/quest.dart';
import '../utils/date_helper.dart';
import '../utils/next_reminder_time.dart';
import '../utils/time_parser.dart';
import 'notification_action_handler.dart';
import 'notification_scheduler.dart';
import 'prefs.dart';

class NotificationService implements NotificationScheduler {
  NotificationService._() : _db = FirebaseFirestore.instance;

  /// Constructor exposed for unit tests. Production code must use
  /// [NotificationService.instance].
  @visibleForTesting
  NotificationService.protected({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _db;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'quest_reminders_v3';
  static const String _channelName = 'Quest Reminders';
  static const String _channelDescription = 'Daily reminders for your quests';

  // ── Init ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('⚠️ Timezone lookup failed, falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: handleAction,
      onDidReceiveBackgroundNotificationResponse: notificationActionHandler,
    );

    _initialized = true;
  }

  // ── Foreground Tap Handler ───────────────────────────────────────────────
  /// Handles the user tapping a notification action while the app is
  /// running (foreground or backgrounded, but the isolate is still alive).
  ///
  /// Exposed as a public method so unit tests can invoke it directly
  /// without needing to simulate platform-level notification taps.
  @visibleForTesting
  Future<void> handleAction(NotificationResponse response) async {
    debugPrint(
      '🔔 Foreground Action: ${response.actionId}, Quest: ${response.payload}',
    );

    // Guard against null and empty payloads. The background handler
    // (notification_action_handler.dart) uses the same guard — keep the two
    // in sync. An empty payload would make `.doc('')` throw a Firestore error
    // that gets swallowed by the try/catch below.
    if (response.payload == null || response.payload!.isEmpty) return;
    final uid = await Prefs.currentUid;
    if (uid == null) return;

    if (response.actionId == 'mark_done') {
      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('quests')
            .doc(response.payload)
            .update({
              'completedDates': FieldValue.arrayUnion([DateHelper.todayIso()]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
        debugPrint(
          '✅ Foreground action: Marked quest ${response.payload} as done.',
        );
      } catch (e) {
        debugPrint('❌ Foreground action failed: $e');
      }
    } else if (response.actionId == 'snooze') {
      debugPrint(
        '✅ Foreground action: Snoozing ${response.payload} for 1 hour.',
      );
      await _scheduleSnooze(response.payload!, uid);
    }
  }

  // ── Snooze Logic ─────────────────────────────────────────────────────────
  Future<void> _scheduleSnooze(String questId, String uid) async {
    // Try to initialize the plugin. On a real device this succeeds; in a
    // headless test environment the platform interface isn't registered,
    // so we log and bail. Firestore lookup still runs, keeping the
    // production path intact.
    if (!_initialized) {
      try {
        await init();
      } catch (e) {
        debugPrint('⚠️ Could not initialize notifications for snooze: $e');
        // Still do the Firestore lookup so we surface any data issues,
        // then bail before touching the plugin.
      }
    }

    String questTitle = 'Your Quest';

    // 1. Fetch the quest title from Firestore
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('quests')
          .doc(questId)
          .get();
      if (doc.exists && doc.data() != null) {
        questTitle = doc.data()!['title'] as String? ?? 'Your Quest';
      }
    } catch (e) {
      debugPrint('⚠️ Could not fetch quest title for snooze: $e');
    }

    if (!_initialized) return; // Plugin not available — nothing to schedule

    // 2. Calculate snooze time
    tz.initializeTimeZones();
    final scheduleTime = tz.TZDateTime.now(tz.local)
        .add(const Duration(hours: 1));

    // 3. Schedule the new notification
    try {
      await _plugin.zonedSchedule(
        snoozeNotificationIdFor(questId),
        'Snoozed Reminder',
        questTitle,
        scheduleTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'mark_done',
                'Mark Done',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                'snooze',
                'Snooze 1h',
                showsUserInterface: true,
                cancelNotification: true,
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(categoryIdentifier: 'quest_reminder'),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: questId,
      );
      debugPrint(
        '✅ Successfully scheduled snooze notification for 1 hour from now.',
      );
    } catch (e) {
      debugPrint('❌ Could not schedule snooze notification: $e');
    }
  }

  // ── Permission ───────────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    if (!_initialized) await init();

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission() ?? false;
      return granted;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted =
          await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }

    return true;
  }

  Future<bool> hasPermission() async {
    if (!_initialized) await init();

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final settings = await ios?.checkPermissions();
      return settings?.isEnabled ?? false;
    }

    return true;
  }

  // ── Scheduling ───────────────────────────────────────────────────────────
  @override
  Future<void> scheduleQuestReminder(Quest quest) async {
    // Best-effort. Never throws — a single quest failing to schedule must
    // not break the reschedule loop in `rescheduleAllForQuests` and must
    // not propagate to VM mutation callers.
    try {
      if (!_initialized) await init();
    } catch (e) {
      debugPrint('❌ Could not init for scheduleQuestReminder: $e');
      return;
    }
    if (!_initialized) return;

    try {
      await cancelQuestReminder(quest.id);
    } catch (e) {
      debugPrint('⚠️ Could not cancel prior reminder for ${quest.id}: $e');
      // Continue — the new schedule will overwrite the old one anyway.
    }

    final time = quest.reminderTime;
    if (time == null || time.isEmpty) return;

    final parsed = TimeParser.parse(time);
    if (parsed == null) return;

    final scheduled = nextReminderTime(parsed.hour, parsed.minute);

    debugPrint('⏰ Scheduling for ${quest.title} at $scheduled');

    try {
      await _plugin.zonedSchedule(
        notificationIdFor(quest.id),
        'Quest time!',
        quest.title,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'mark_done',
                'Mark Done',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                'snooze',
                'Snooze 1h',
                showsUserInterface: true,
                cancelNotification: true,
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(categoryIdentifier: 'quest_reminder'),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: quest.id,
      );
      debugPrint('✅ Successfully scheduled notification');
    } catch (e) {
      debugPrint('❌ Could not schedule notification: $e');
    }
  }

  @override
  Future<void> cancelQuestReminder(String questId) async {
    // Best-effort. Never throws.
    try {
      if (!_initialized) await init();
      if (!_initialized) return;
      await _plugin.cancel(notificationIdFor(questId));
    } catch (e) {
      debugPrint('⚠️ Could not cancel reminder for $questId: $e');
    }
  }

  @override
  Future<void> cancelAll() async {
    // Best-effort. Never throws.
    try {
      if (!_initialized) await init();
      if (!_initialized) return;
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('⚠️ Could not cancel all notifications: $e');
    }
  }

  @override
  Future<void> rescheduleAllForQuests(List<Quest> quests) async {
    // Best-effort. Never throws — one bad quest must not skip the rest.
    try {
      if (!_initialized) await init();
      if (!_initialized) return;
    } catch (e) {
      debugPrint('❌ Could not init for rescheduleAllForQuests: $e');
      return;
    }

    await cancelAll();

    for (final q in quests) {
      try {
        await scheduleQuestReminder(q);
      } catch (e) {
        // scheduleQuestReminder is documented non-throwing, but keep this
        // as a last-resort guard so a future regression can't break the loop.
        debugPrint('⚠️ Skipping quest ${q.id} during reschedule: $e');
      }
    }
  }
}
