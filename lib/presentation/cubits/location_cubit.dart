import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/location_service.dart';
import '../../data/models/location_model.dart';

sealed class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationManualState extends LocationState {
  final ManualLocation location;
  const LocationManualState(this.location);
}

class LocationGpsState extends LocationState {
  final GpsLocation location;
  const LocationGpsState(this.location);
}

class LocationDenied extends LocationState {
  final ManualLocation fallback;
  const LocationDenied(this.fallback);
}

class LocationCubit extends Cubit<LocationState> {
  final ILocationService _service;
  StreamSubscription? _sub;

  LocationCubit(this._service) : super(const LocationInitial());

  void setManual(ManualLocation loc) {
    _sub?.cancel();
    emit(LocationManualState(loc));
  }

  Future<void> enableGps({
    required ManualLocation fallback,
    double distanceFilterMeters = 5000,
  }) async {
    final perm = await _service.requestPermission();
    if (perm != LocationPermissionResult.granted) {
      emit(LocationDenied(fallback));
      return;
    }
    _sub?.cancel();
    _sub = _service
        .watch(distanceFilterMeters: distanceFilterMeters)
        .listen((p) => emit(LocationGpsState(
              GpsLocation(lat: p.lat, lng: p.lng, accuracy: p.accuracy),
            )));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
