import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/esma_model.dart';

abstract class IEsmaRepository {
  Future<void> load();

  /// 99 names list. Empty until [load] resolves.
  List<EsmaModel> getAll();

  /// Deterministic by Unix day — same name shown for everyone on a given
  /// calendar date, rotates daily across all 99.
  EsmaModel getDaily([DateTime? now]);

  /// Lookup by canonical 1-99 id.
  EsmaModel getById(int id);
}

/// Loads the bundled `assets/data/esma_ul_husna.json` at startup. Content is
/// public-domain religious facts (the canonical 99 names + classical Turkish
/// glosses). No network, no caching — the JSON is small enough to live in
/// memory for the app's lifetime.
class EsmaRepository implements IEsmaRepository {
  static const _assetPath = 'assets/data/esma_ul_husna.json';

  List<EsmaModel> _items = const [];

  @override
  Future<void> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = json.decode(raw) as List<dynamic>;
    _items = list
        .map((e) => EsmaModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  List<EsmaModel> getAll() => _items;

  @override
  EsmaModel getDaily([DateTime? now]) {
    assert(_items.isNotEmpty, 'EsmaRepository.load() must run before getDaily');
    final day = (now ?? DateTime.now())
            .toUtc()
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return _items[day % _items.length];
  }

  @override
  EsmaModel getById(int id) => _items.firstWhere((e) => e.id == id);
}
