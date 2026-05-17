sealed class LocationModel {
  const LocationModel();

  double get lat;
  double get lng;
}

class ManualLocation extends LocationModel {
  final String country;
  final String city;
  final String district;
  @override
  final double lat;
  @override
  final double lng;

  const ManualLocation({
    required this.country,
    required this.city,
    required this.district,
    required this.lat,
    required this.lng,
  });
}

class GpsLocation extends LocationModel {
  @override
  final double lat;
  @override
  final double lng;
  final double? accuracy;

  const GpsLocation({
    required this.lat,
    required this.lng,
    this.accuracy,
  });
}
