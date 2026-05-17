import 'package:flutter/material.dart';
import '../../core/constants/theme.dart';

/// Vector logo mark for İrfan Takvimi.
///
/// Intentionally minimalist Islamic-only vocabulary (per CLAUDE.md §1 Imagery
/// Guardrail): no star polygons, no radial rays, no shape that could be
/// confused with Star of David or any non-Islamic mark. Just:
///   • outer copper hairline ring
///   • inner thinner copper ring
///   • bold central crescent moon
///   • a single small copper ornamental dot at the top of the outer ring
///     (Ottoman manuscript bezeme — unambiguously decorative, not figurative)
///
/// The [onHeritage] flag swaps the crescent fill from deep emerald to cream
/// so it reads on dark heritage cards as well as the ivory ground.
class AppLogo extends StatelessWidget {
  final double size;
  final bool onHeritage;
  const AppLogo({super.key, this.size = 72, this.onHeritage = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Crescent fill picks the color that pops against the surface it sits on:
    //   - explicitly onHeritage → cream
    //   - dark theme (dark ground) → cream
    //   - otherwise (light theme on ivory) → deep heritage emerald
    final crescentColor =
        (onHeritage || isDark) ? p.cream : p.heritage;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LogoPainter(
          stroke: p.copper,
          strokeSoft: p.copper.withOpacity(0.55),
          crescent: crescentColor,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color stroke;
  final Color strokeSoft;
  final Color crescent;
  _LogoPainter({
    required this.stroke,
    required this.strokeSoft,
    required this.crescent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    final outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.045
      ..color = stroke;
    final innerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.022
      ..color = strokeSoft;
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = stroke;
    final crescentFill = Paint()
      ..style = PaintingStyle.fill
      ..color = crescent;

    final outerR = r * 0.94;
    canvas.drawCircle(c, outerR, outerRing);
    canvas.drawCircle(c, r * 0.78, innerRing);

    // Single ornamental dot sitting on the top of the outer ring (12 o'clock).
    // Pure manuscript-style bezeme — one dot is not a star.
    canvas.drawCircle(Offset(c.dx, c.dy - outerR), r * 0.07, dot);

    // Crescent: full disk with a slightly offset disk punched out via
    // BlendMode.dstOut on a saved layer. Slight downward bias balances the
    // top ornamental dot visually.
    final crescentR = r * 0.46;
    final cc = Offset(c.dx, c.dy + r * 0.04);
    final offset = Offset(crescentR * 0.42, -crescentR * 0.08);
    final layerRect = Rect.fromCircle(center: cc, radius: crescentR * 1.4);
    canvas.saveLayer(layerRect, Paint());
    canvas.drawCircle(cc, crescentR, crescentFill);
    canvas.drawCircle(
      cc + offset,
      crescentR * 0.92,
      Paint()..blendMode = BlendMode.dstOut,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) =>
      old.stroke != stroke ||
      old.strokeSoft != strokeSoft ||
      old.crescent != crescent;
}
