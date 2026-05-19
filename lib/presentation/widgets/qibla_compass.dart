import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/constants/theme.dart';

class QiblaCompass extends StatelessWidget {
  final double headingDegrees;
  final double qiblaBearingDegrees;
  final double size;

  const QiblaCompass({
    super.key,
    required this.headingDegrees,
    required this.qiblaBearingDegrees,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    final delta = (qiblaBearingDegrees - headingDegrees) * math.pi / 180.0;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(angle: delta, palette: context.palette),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double angle;
  final AppPalette palette;

  _CompassPainter({required this.angle, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;

    final ring = Paint()
      ..color = palette.copper.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ring);

    final innerRing = Paint()
      ..color = palette.heritage.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.7, innerRing);

    final tick = Paint()..color = palette.ink.withOpacity(0.5);
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final p1 = center + Offset(math.sin(a) * radius, -math.cos(a) * radius);
      final p2 = center +
          Offset(math.sin(a) * (radius - 10), -math.cos(a) * (radius - 10));
      canvas.drawLine(p1, p2, tick..strokeWidth = i == 0 ? 3 : 1);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final needle = Path()
      ..moveTo(0, -radius * 0.78)
      ..lineTo(12, 0)
      ..lineTo(0, 16)
      ..lineTo(-12, 0)
      ..close();
    final needlePaint = Paint()..color = palette.heritage;
    canvas.drawPath(needle, needlePaint);

    final tip = Paint()..color = palette.copper;
    canvas.drawCircle(Offset(0, -radius * 0.78), 6, tip);

    canvas.restore();

    final dot = Paint()..color = palette.ink;
    canvas.drawCircle(center, 4, dot);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) =>
      old.angle != angle || old.palette != palette;
}
