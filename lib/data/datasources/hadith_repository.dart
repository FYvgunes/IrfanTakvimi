import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';

import '../models/hadith_model.dart';
import 'hadith_api_client.dart';

abstract class IHadithRepository {
  Future<void> load();
  HadithModel getDaily([DateTime? now]);
  HadithModel getById(int id);
  List<HadithModel> getAll();
  int get count;
}

/// Loads a sahih hadith collection (default: Sahih al-Bukhari in Turkish) on
/// first run from the fawazahmed0/hadith-api CDN, caches the full list in
/// Hive, and uses the cache on subsequent runs. If the network is unavailable
/// on the very first launch (no cache yet), falls back to the bundled seed in
/// `assets/data/hadiths.json` so the UI always has *something* to show.
class HadithRepository implements IHadithRepository {
  static const _assetPath = 'assets/data/hadiths.json';
  static const boxName = 'hadith_cache';
  static const _cacheKey = 'items_v1';

  final Box _cache;
  final HadithApiClient _client;

  List<HadithModel> _items = const [];

  HadithRepository({required Box cache, HadithApiClient? client})
      : _cache = cache,
        _client = client ?? HadithApiClient();

  static Future<Box> openBox() => Hive.openBox(boxName);

  @override
  int get count => _items.length;

  @override
  Future<void> load() async {
    // Cache wins when present — no extra fetch on warm starts.
    final cached = _cache.get(_cacheKey);
    if (cached is String) {
      _items = _decode(cached);
      return;
    }
    // First run: try API, fall back to bundled seed on failure.
    try {
      final fresh = await _client.fetchEdition();
      _items = fresh;
      await _cache.put(_cacheKey, _encode(fresh));
    } catch (_) {
      _items = await _loadBundled();
    }
  }

  @override
  HadithModel getDaily([DateTime? now]) {
    assert(_items.isNotEmpty, 'HadithRepository.load() must run before getDaily');
    final day = (now ?? DateTime.now())
            .toUtc()
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return _items[day % _items.length];
  }

  @override
  HadithModel getById(int id) => _items.firstWhere((h) => h.id == id);

  @override
  List<HadithModel> getAll() => _items;

  Future<List<HadithModel>> _loadBundled() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => HadithModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  String _encode(List<HadithModel> items) => json.encode(items
      .map((h) => {
            'id': h.id,
            'text': h.text,
            'source': h.source,
            'hadith_no': h.hadithNo,
          })
      .toList());

  List<HadithModel> _decode(String raw) {
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => HadithModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
