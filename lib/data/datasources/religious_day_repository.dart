import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/religious_day_model.dart';

abstract class IReligiousDayRepository {
  Future<void> load();

  /// Religious day on [date], or null. Compared by year+month+day only.
  ReligiousDay? byDate(DateTime date);

  /// All religious days in [year]/[month] (1-12). Sorted ascending by date.
  List<ReligiousDay> byMonth(int year, int month);

  /// Full list, ascending by date.
  List<ReligiousDay> all();
}

/// Loads the bundled `assets/data/religious_days.json` at startup. Data is
/// the Türkiye Diyanet İşleri Başkanlığı resmi takvimi for 2026+ —
/// kullanıcı her yıl güncellemek/doğrulamak ile sorumlu (kaynak:
/// https://namazvakitleri.diyanet.gov.tr/tr-TR/dini-gunler).
class ReligiousDayRepository implements IReligiousDayRepository {
  static const _assetPath = 'assets/data/religious_days.json';

  List<ReligiousDay> _items = const [];

  @override
  Future<void> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = json.decode(raw) as List<dynamic>;
    final parsed = list
        .map((e) => ReligiousDay.fromJson(e as Map<String, dynamic>))
        .toList();
    parsed.sort((a, b) => a.date.compareTo(b.date));
    _items = List.unmodifiable(parsed);
  }

  @override
  ReligiousDay? byDate(DateTime date) {
    for (final d in _items) {
      if (d.date.year == date.year &&
          d.date.month == date.month &&
          d.date.day == date.day) {
        return d;
      }
    }
    return null;
  }

  @override
  List<ReligiousDay> byMonth(int year, int month) => _items
      .where((d) => d.date.year == year && d.date.month == month)
      .toList(growable: false);

  @override
  List<ReligiousDay> all() => _items;
}
