import 'dart:math' as math;

class QiblaCalculator {
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  static double bearing({
    required double lat,
    required double lng,
  }) {
    final phi1 = _deg2rad(lat);
    final phi2 = _deg2rad(kaabaLat);
    final dLambda = _deg2rad(kaabaLng - lng);

    final y = math.sin(dLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLambda);

    final theta = math.atan2(y, x);
    return (_rad2deg(theta) + 360) % 360;
  }

  static double _deg2rad(double deg) => deg * math.pi / 180.0;
  static double _rad2deg(double rad) => rad * 180.0 / math.pi;
}
