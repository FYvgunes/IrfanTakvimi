import 'package:flutter/widgets.dart';
import '../../core/constants/theme.dart';

enum CardVariant {
  /// Light card on the ivory ground, hairline copper border. In dark mode
  /// renders as a slightly raised dark surface from `context.palette.groundSoft`.
  ivory,

  /// Deep emerald heritage card with a copper top rule. Intentionally similar
  /// in both light and dark modes (heritage is a brand-color card, not a
  /// surface).
  heritage,
}

class ArtisticCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final CardVariant variant;

  const ArtisticCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = const EdgeInsets.all(AppSpacing.sm),
    this.variant = CardVariant.ivory,
  });

  bool get _isHeritage => variant == CardVariant.heritage;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = _isHeritage ? p.heritage : p.groundSoft;
    final borderColor = _isHeritage
        ? p.copper.withOpacity(0.55)
        : p.copper.withOpacity(0.30);
    final shadowColor = _isHeritage
        ? p.heritageEdge.withOpacity(0.35)
        : p.ink.withOpacity(0.06);

    final card = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (_isHeritage)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      p.copper.withOpacity(0.0),
                      p.copper,
                      p.copper.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.card),
                  ),
                ),
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );

    return Padding(padding: margin, child: card);
  }
}
