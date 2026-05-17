import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DistrictEntry {
  final String name;
  final double lat;
  final double lng;
  const DistrictEntry({required this.name, required this.lat, required this.lng});

  factory DistrictEntry.fromJson(Map<String, dynamic> j) => DistrictEntry(
        name: j['name'] as String,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
      );
}

class CityEntry {
  final String name;
  final List<DistrictEntry> districts;
  const CityEntry({required this.name, required this.districts});

  factory CityEntry.fromJson(Map<String, dynamic> j) => CityEntry(
        name: j['name'] as String,
        districts: (j['districts'] as List<dynamic>)
            .map((e) => DistrictEntry.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );
}

class CountryEntry {
  final String code;
  final String name;
  final List<CityEntry> cities;
  const CountryEntry({
    required this.code,
    required this.name,
    required this.cities,
  });

  factory CountryEntry.fromJson(Map<String, dynamic> j) => CountryEntry(
        code: j['country'] as String,
        name: j['country_name'] as String,
        cities: (j['cities'] as List<dynamic>)
            .map((e) => CityEntry.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );
}

abstract class ILocationRepository {
  Future<void> load();
  List<CountryEntry> get countries;
}

class LocationRepository implements ILocationRepository {
  static const _assetPath = 'assets/data/locations.json';
  List<CountryEntry> _countries = const [];

  @override
  List<CountryEntry> get countries => _countries;

  @override
  Future<void> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = json.decode(raw) as List<dynamic>;
    _countries = list
        .map((e) => CountryEntry.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
