import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:irfan_takvim/data/datasources/aladhan_client.dart';
import 'package:irfan_takvim/data/datasources/prayer_repository.dart';
import 'package:irfan_takvim/data/models/location_model.dart';

void main() {
  late Directory tempDir;
  late Box box;
  late int apiCallCount;

  const loc = ManualLocation(
    country: 'TR',
    city: 'İstanbul',
    district: 'Üsküdar',
    lat: 41.0233,
    lng: 29.0151,
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('prayer_cache_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox('prayer_cache_test');
    apiCallCount = 0;
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  String fakeMonthBody(int year, int month, {String fajr = '05:23'}) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final data = List.generate(daysInMonth, (i) {
      final day = i + 1;
      return {
        'timings': {
          'Fajr': fajr,
          'Dhuhr': '13:05',
          'Asr': '16:35',
          'Maghrib': '19:50',
          'Isha': '21:20',
        },
        'date': {
          'gregorian': {
            'date': '${day.toString().padLeft(2, "0")}-'
                '${month.toString().padLeft(2, "0")}-$year',
          },
        },
      };
    });
    return json.encode({'code': 200, 'status': 'OK', 'data': data});
  }

  PrayerRepository buildRepo({
    required Future<http.Response> Function(http.Request) handler,
    DateTime Function()? now,
    Duration? ttl,
  }) {
    final mockClient = MockClient((req) async {
      apiCallCount++;
      return handler(req);
    });
    return PrayerRepository(
      cache: box,
      client: AladhanClient(httpClient: mockClient),
      now: now,
      ttl: ttl,
    );
  }

  group('PrayerRepository.getMonth', () {
    test('first call fetches from API and caches the result', () async {
      final repo = buildRepo(
        handler: (_) async => http.Response(fakeMonthBody(2026, 5), 200),
        now: () => DateTime(2026, 5, 17),
      );

      final result = await repo.getMonth(loc, DateTime(2026, 5));

      expect(result, hasLength(31));
      expect(result.first.date, DateTime(2026, 5, 1));
      expect(result.first.prayers.first.name, 'İmsak');
      expect(apiCallCount, 1);
      expect(box.keys, isNotEmpty);
    });

    test('cache hit within TTL skips the API', () async {
      final repo = buildRepo(
        handler: (_) async => http.Response(fakeMonthBody(2026, 12), 200),
        now: () => DateTime(2026, 5, 1),
      );
      await repo.getMonth(loc, DateTime(2026, 12));
      expect(apiCallCount, 1);

      // 29 days later: still within 30-day TTL.
      final repo2 = buildRepo(
        handler: (_) async =>
            fail('API must not be hit while cache is fresh'),
        now: () => DateTime(2026, 5, 30),
      );
      final result = await repo2.getMonth(loc, DateTime(2026, 12));

      expect(result, hasLength(31));
      expect(apiCallCount, 1);
    });

    test('expired cache for a future month triggers a refetch', () async {
      // Seed cache at 2026-05-01 for the (future) month of 2026-12.
      final seed = buildRepo(
        handler: (_) async =>
            http.Response(fakeMonthBody(2026, 12, fajr: '05:23'), 200),
        now: () => DateTime(2026, 5, 1),
      );
      await seed.getMonth(loc, DateTime(2026, 12));
      expect(apiCallCount, 1);

      // 35 days later: past 30-day TTL, December is still in the future.
      final refetch = buildRepo(
        handler: (_) async =>
            http.Response(fakeMonthBody(2026, 12, fajr: '05:30'), 200),
        now: () => DateTime(2026, 6, 5),
      );
      final result = await refetch.getMonth(loc, DateTime(2026, 12));

      expect(apiCallCount, 2);
      expect(result.first.prayers.first.time.hour, 5);
      expect(result.first.prayers.first.time.minute, 30,
          reason: 'refetched value, not the stale 05:23');
    });

    test('past months never expire even years later', () async {
      final seed = buildRepo(
        handler: (_) async => http.Response(fakeMonthBody(2026, 1), 200),
        now: () => DateTime(2026, 1, 1),
      );
      await seed.getMonth(loc, DateTime(2026, 1));
      expect(apiCallCount, 1);

      // A year and a half later — way past TTL — but January 2026 is history.
      final later = buildRepo(
        handler: (_) async =>
            fail('Past months must not trigger refetch'),
        now: () => DateTime(2027, 7, 1),
      );
      final result = await later.getMonth(loc, DateTime(2026, 1));

      expect(result, hasLength(31));
      expect(apiCallCount, 1);
    });

    test('stale-while-error: returns stale cache when refresh fails',
        () async {
      // Seed a future month.
      final seed = buildRepo(
        handler: (_) async =>
            http.Response(fakeMonthBody(2026, 12, fajr: '05:23'), 200),
        now: () => DateTime(2026, 5, 1),
      );
      await seed.getMonth(loc, DateTime(2026, 12));
      expect(apiCallCount, 1);

      // 60 days later: TTL expired. API returns 500.
      final brokenApi = buildRepo(
        handler: (_) async => http.Response('upstream error', 500),
        now: () => DateTime(2026, 7, 1),
      );
      final result = await brokenApi.getMonth(loc, DateTime(2026, 12));

      expect(apiCallCount, 2, reason: 'attempted refresh');
      expect(result, hasLength(31), reason: 'fell back to stale cache');
      expect(result.first.prayers.first.time.minute, 23,
          reason: 'served the original cached value');
    });

    test('no cache + API error yields an empty list', () async {
      final repo = buildRepo(
        handler: (_) async => http.Response('boom', 500),
        now: () => DateTime(2026, 5, 17),
      );

      final result = await repo.getMonth(loc, DateTime(2026, 5));

      expect(result, isEmpty);
      expect(apiCallCount, 1);
    });
  });

  group('PrayerRepository.getToday', () {
    test('returns today\'s schedule from the current month', () async {
      final repo = buildRepo(
        handler: (_) async => http.Response(fakeMonthBody(2026, 5), 200),
        now: () => DateTime(2026, 5, 17, 12, 0),
      );

      final today = await repo.getToday(loc);

      expect(today, isNotNull);
      expect(today!.date, DateTime(2026, 5, 17));
    });

    test('returns null when no cache and the API fails', () async {
      final repo = buildRepo(
        handler: (_) async => http.Response('boom', 500),
        now: () => DateTime(2026, 5, 17),
      );

      final today = await repo.getToday(loc);

      expect(today, isNull);
    });
  });
}
