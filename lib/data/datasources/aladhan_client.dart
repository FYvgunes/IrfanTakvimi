import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prayer_time_model.dart';

/// Thin client for the Aladhan prayer-times API.
///
/// Uses `method=13` (Diyanet İşleri Başkanlığı, TR) and `school=1` (Hanafi
/// Asr), matching the conventions Diyanet publishes for Turkey.
class AladhanClient {
  static const _base = 'https://api.aladhan.com/v1';
  static const _methodDiyanet = 13;
  static const _schoolHanafi = 1;

  final http.Client _http;
  final Duration _timeout;

  AladhanClient({http.Client? httpClient, Duration? timeout})
      : _http = httpClient ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 15);

  Future<List<DailyPrayerSchedule>> fetchMonth({
    required double lat,
    required double lng,
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse(
      '$_base/calendar/$year/$month'
      '?latitude=$lat&longitude=$lng'
      '&method=$_methodDiyanet&school=$_schoolHanafi',
    );
    final res = await _http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Aladhan ${res.statusCode} for $uri');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((day) => _parseDay(day as Map<String, dynamic>))
        .toList(growable: false);
  }

  DailyPrayerSchedule _parseDay(Map<String, dynamic> day) {
    final timings = day['timings'] as Map<String, dynamic>;
    final gregorian =
        (day['date'] as Map<String, dynamic>)['gregorian'] as Map<String, dynamic>;
    final parts = (gregorian['date'] as String).split('-'); // DD-MM-YYYY
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    return DailyPrayerSchedule(
      date: date,
      prayers: [
        _prayer(PrayerName.fajr, 'İmsak', date, timings['Fajr'] as String),
        _prayer(PrayerName.dhuhr, 'Öğle', date, timings['Dhuhr'] as String),
        _prayer(PrayerName.asr, 'İkindi', date, timings['Asr'] as String),
        _prayer(PrayerName.maghrib, 'Akşam', date, timings['Maghrib'] as String),
        _prayer(PrayerName.isha, 'Yatsı', date, timings['Isha'] as String),
      ],
    );
  }

  PrayerTime _prayer(PrayerName key, String name, DateTime date, String raw) {
    // Aladhan returns timings like "05:23" or "05:23 (+03)"; keep HH:MM only.
    final hm = raw.split(' ').first.split(':');
    return PrayerTime(
      key: key,
      name: name,
      time: DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(hm[0]),
        int.parse(hm[1]),
      ),
    );
  }

  void dispose() => _http.close();
}
