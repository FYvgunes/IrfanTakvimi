import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class GeoPoint {
  final double lat;
  final double lng;
  final double? accuracy;
  const GeoPoint(this.lat, this.lng, {this.accuracy});
}

enum LocationPermissionResult { granted, denied, deniedForever, serviceDisabled }

abstract class ILocationService {
  Future<LocationPermissionResult> requestPermission();
  Future<GeoPoint?> getCurrent();
  Stream<GeoPoint> watch({double distanceFilterMeters = 5000});
  bool get isHardwareSupported;
}

class LocationService implements ILocationService {
  @override
  bool get isHardwareSupported => !kIsWeb || _webGeolocationAvailable();

  bool _webGeolocationAvailable() => true;

  @override
  Future<LocationPermissionResult> requestPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return LocationPermissionResult.serviceDisabled;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    switch (perm) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionResult.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionResult.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionResult.denied;
    }
  }

  @override
  Future<GeoPoint?> getCurrent() async {
    try {
      final p = await Geolocator.getCurrentPosition();
      return GeoPoint(p.latitude, p.longitude, accuracy: p.accuracy);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<GeoPoint> watch({double distanceFilterMeters = 5000}) {
    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters.toInt(),
    );
    return Geolocator.getPositionStream(locationSettings: settings)
        .map((p) => GeoPoint(p.latitude, p.longitude, accuracy: p.accuracy));
  }
}
