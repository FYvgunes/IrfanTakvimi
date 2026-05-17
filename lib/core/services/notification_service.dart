import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/prayer_time_model.dart';
import '../../data/models/hadith_model.dart';

abstract class INotificationService {
  Future<void> init();
  bool get isSupported;
  Future<void> schedulePrayerNotifications({
    required List<PrayerTime> prayerTimes,
    required HadithModel hadith,
  });
  Future<void> cancelAll();
}

class NotificationService implements INotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  Future<void> init() async {
    if (!isSupported) return;
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(init);
  }

  @override
  Future<void> schedulePrayerNotifications({
    required List<PrayerTime> prayerTimes,
    required HadithModel hadith,
  }) async {
    if (!isSupported) return;
    await cancelAll();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel',
        'Namaz Vakitleri',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    for (var i = 0; i < prayerTimes.length; i++) {
      final p = prayerTimes[i];
      await _plugin.zonedSchedule(
        i,
        p.name,
        hadith.text,
        tz.TZDateTime.from(p.time, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '${hadith.source}#${hadith.hadithNo}',
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    if (!isSupported) return;
    await _plugin.cancelAll();
  }
}
