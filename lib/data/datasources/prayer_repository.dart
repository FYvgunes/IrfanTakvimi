import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/location_model.dart';
import '../models/prayer_time_model.dart';
import 'aladhan_client.dart';

abstract class IPrayerRepository {
  Future<DailyPrayerSchedule?> getToday(LocationModel location);
  Future<List<DailyPrayerSchedule>> getMonth(
    LocationModel location,
    DateTime month,
  );
}

/// Fetches monthly prayer schedules from Aladhan (Diyanet method) and caches
/// each month in Hive keyed by rounded coordinates so repeat visits and
/// offline use cost zero network.
///
/// TTL: 30 days for the current month and later. Past months never expire —
/// once a month has ended its times are historical and immutable, so re-fetch
/// would be wasted bandwidth.
///
/// Stale-while-error: when a refresh fails (offline, API down), expired cached
/// data is still returned rather than an empty list.
class PrayerRepository implements IPrayerRepository {
  static const boxName = 'prayer_cache';
  static const Duration defaultTtl = Duration(days: 30);

  final AladhanClient _client;
  final Box _cache;
  final Duration _ttl;
  final DateTime Function() _now;

  PrayerRepository({
    required Box cache,
    AladhanClient? client,
    Duration? ttl,
    DateTime Function()? now,
  })  : _cache = cache,
        _client = client ?? AladhanClient(),
        _ttl = ttl ?? defaultTtl,
        _now = now ?? DateTime.now;

  static Future<Box> openBox() => Hive.openBox(boxName);

  @override
  Future<DailyPrayerSchedule?> getToday(LocationModel location) async {
    final now = _now();
    final month = await getMonth(location, DateTime(now.year, now.month));
    for (final s in month) {
      if (s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day) {
        return s;
      }
    }
    return null;
  }

  @override
  Future<List<DailyPrayerSchedule>> getMonth(
    LocationModel location,
    DateTime month,
  ) async {
    final key = _cacheKey(location.lat, location.lng, month.year, month.month);
    final entry = _readEntry(_cache.get(key));

    if (entry != null && !_isExpired(entry.cachedAt, month)) {
      return entry.data;
    }

    try {
      final fresh = await _client.fetchMonth(
        lat: location.lat,
        lng: location.lng,
        year: month.year,
        month: month.month,
      );
      await _cache.put(key, _encode(fresh, _now()));
      return fresh;
    } catch (_) {
      // Stale-while-error: fall back to expired cache if we have one.
      return entry?.data ?? const [];
    }
  }

  bool _isExpired(DateTime cachedAt, DateTime month) {
    final now = _now();
    // Months that have already ended are immutable — never expire.
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    if (monthEnd.isBefore(now)) return false;
    return now.difference(cachedAt) > _ttl;
  }

  // Round coordinates to ~100 m precision (4 decimals) so nearby GPS samples
  // share a cache entry without making it useless for distinct districts.
  String _cacheKey(double lat, double lng, int year, int month) =>
      '${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)},'
      '$year-${month.toString().padLeft(2, '0')}';

  String _encode(List<DailyPrayerSchedule> schedules, DateTime cachedAt) =>
      json.encode({
        'cachedAt': cachedAt.toIso8601String(),
        'data': schedules
            .map((s) => {
                  'd': s.date.toIso8601String(),
                  'p': s.prayers
                      .map((p) => {
                            'k': p.key.name,
                            'n': p.name,
                            't': p.time.toIso8601String(),
                          })
                      .toList(),
                })
            .toList(),
      });

  _CacheEntry? _readEntry(Object? raw) {
    if (raw is! String) return null;
    final decoded = json.decode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    final cachedAtRaw = decoded['cachedAt'];
    final dataRaw = decoded['data'];
    if (cachedAtRaw is! String || dataRaw is! List) return null;
    return _CacheEntry(
      cachedAt: DateTime.parse(cachedAtRaw),
      data: _decodeData(dataRaw),
    );
  }

  List<DailyPrayerSchedule> _decodeData(List<dynamic> data) =>
      data.map((e) {
        final m = e as Map<String, dynamic>;
        final prayers = (m['p'] as List<dynamic>)
            .map((p) {
              final pm = p as Map<String, dynamic>;
              return PrayerTime(
                key: PrayerName.values.byName(pm['k'] as String),
                name: pm['n'] as String,
                time: DateTime.parse(pm['t'] as String),
              );
            })
            .toList(growable: false);
        return DailyPrayerSchedule(
          date: DateTime.parse(m['d'] as String),
          prayers: prayers,
        );
      }).toList(growable: false);
}

class _CacheEntry {
  final DateTime cachedAt;
  final List<DailyPrayerSchedule> data;
  const _CacheEntry({required this.cachedAt, required this.data});
}
