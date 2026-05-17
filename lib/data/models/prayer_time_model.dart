enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

class PrayerTime {
  final PrayerName key;
  final String name;
  final DateTime time;

  const PrayerTime({
    required this.key,
    required this.name,
    required this.time,
  });
}

class DailyPrayerSchedule {
  final DateTime date;
  final List<PrayerTime> prayers;

  const DailyPrayerSchedule({required this.date, required this.prayers});
}
