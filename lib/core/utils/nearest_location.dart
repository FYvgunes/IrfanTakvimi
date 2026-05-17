import 'dart:math';

import '../../data/datasources/location_repository.dart';

class NearestMatch {
  final CityEntry city;
  final DistrictEntry district;
  final double distanceKm;
  const NearestMatch({
    required this.city,
    required this.district,
    required this.distanceKm,
  });
}

/// Find the city/district whose stored coordinates lie closest to the given
/// GPS point. Iterates every district so once district-level coords replace
/// the current province-inherited values, the lookup becomes finer-grained
/// automatically — no caller change needed.
NearestMatch? nearestLocation({
  required double lat,
  required double lng,
  required List<CountryEntry> countries,
}) {
  NearestMatch? best;
  for (final country in countries) {
    for (final city in country.cities) {
      for (final d in city.districts) {
        final km = _haversineKm(lat, lng, d.lat, d.lng);
        if (best == null || km < best.distanceKm) {
          best = NearestMatch(city: city, district: d, distanceKm: km);
        }
      }
    }
  }
  return best;
}

double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0; // earth mean radius, km
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) *
          cos(_toRad(lat2)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  return 2 * r * asin(sqrt(a));
}

double _toRad(double deg) => deg * pi / 180.0;
