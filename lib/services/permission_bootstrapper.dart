import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionBootstrapper {
  const PermissionBootstrapper._();

  /// Returns true if we need to show the custom UI prompt.
  static Future<bool> needsPermissions() async {
    if (!Platform.isAndroid) return false;

    final notif = await Permission.notification.status;
    final alarm = await Permission.scheduleExactAlarm.status;
    final battery = await Permission.ignoreBatteryOptimizations.status;

    return !notif.isGranted || !alarm.isGranted || !battery.isGranted;
  }

  /// Triggers the actual native popups.
  static Future<void> requestAll() async {
    if (!Platform.isAndroid) return;

    final notifStatus = await Permission.notification.request();
    debugPrint('Notification Permission: $notifStatus');

    final alarmStatus = await Permission.scheduleExactAlarm.request();
    debugPrint('Exact Alarm Permission: $alarmStatus');

    final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
    debugPrint('Battery Optimization Permission: $batteryStatus');
  }
}
