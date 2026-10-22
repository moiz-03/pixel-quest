import 'dart:ui';

import 'notification_id.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../firebase_options.dart';
import '../utils/date_helper.dart';

@pragma('vm:entry-point')
Future<void> notificationActionHandler(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('🔔 Background action received: ${response.actionId}');

  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('pq_user_id');

  if (uid == null || response.payload == null || response.payload!.isEmpty) {
    debugPrint('❌ Handler: Missing uid or payload');
    return;
  }

  final questId = response.payload!;
  final firestore = FirebaseFirestore.instance;

  if (response.actionId == 'mark_done') {
    debugPrint('✅ Handler: Attempting to mark $questId done');
    try {
      final docRef = firestore
          .collection('users')
          .doc(uid)
          .collection('quests')
          .doc(questId);

      await docRef.update({
        'completedDates': FieldValue.arrayUnion([DateHelper.todayIso()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Handler: Successfully marked $questId done.');
    } catch (e) {
      debugPrint('❌ Handler: Failed to mark done - $e');
    }
  } else if (response.actionId == 'snooze') {
    debugPrint('✅ Handler: Snoozing $questId for 1 hour');

    String questTitle = 'Your Quest';
    try {
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('quests')
          .doc(questId)
          .get();
      if (doc.exists && doc.data() != null) {
        questTitle = doc.data()!['title'] as String? ?? 'Your Quest';
      }
    } catch (_) {}

    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    final scheduleTime = tz.TZDateTime.now(tz.local)
        .add(const Duration(hours: 1));

    await plugin.zonedSchedule(
      // Same ID as the foreground _scheduleSnooze path. Both paths must
      // produce the same ID so a snooze from one cannot coexist with a
      // snooze from the other, and so the value is stable across Dart SDK
      // versions (String.hashCode is NOT stable across SDKs).
      snoozeNotificationIdFor(questId),
      'Snoozed Reminder',
      questTitle,
      scheduleTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quest_reminders_v3',
          'Quest Reminders',
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
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: questId,
    );
  }
}
