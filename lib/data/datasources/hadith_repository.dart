import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/hadith_model.dart';

abstract class IHadithRepository {
  Future<void> load();
  HadithModel getDaily([DateTime? now]);
  HadithModel getById(int id);
  List<HadithModel> getAll();
  int get count;
}

class HadithRepository implements IHadithRepository {
  static const _assetPath = 'assets/data/hadiths.json';
  List<HadithModel> _items = const [];

  @override
  int get count => _items.length;

  @override
  Future<void> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = json.decode(raw) as List<dynamic>;
    _items = list
        .map((e) => HadithModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
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
}
