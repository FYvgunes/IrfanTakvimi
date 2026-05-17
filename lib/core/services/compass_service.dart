import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_compass/flutter_compass.dart';

abstract class ICompassService {
  bool get isSupported;
  Stream<double> headingStream();
}

class CompassService implements ICompassService {
  @override
  bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Stream<double> headingStream() {
    if (!isSupported) return const Stream<double>.empty();
    return FlutterCompass.events
        ?.map((e) => e.heading ?? 0)
        .where((h) => h.isFinite) ??
        const Stream<double>.empty();
  }
}
