import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

class Responsive {
  static double _w(BuildContext c) => MediaQuery.of(c).size.width;

  static bool isMobile(BuildContext c) => _w(c) < Breakpoints.mobile;
  static bool isTablet(BuildContext c) =>
      _w(c) >= Breakpoints.mobile && _w(c) < Breakpoints.tablet;
  static bool isDesktop(BuildContext c) => _w(c) >= Breakpoints.tablet;

  static T value<T>(
    BuildContext c, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(c)) return desktop ?? tablet ?? mobile;
    if (isTablet(c)) return tablet ?? mobile;
    return mobile;
  }
}
