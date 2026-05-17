import 'package:flutter/material.dart';

import '../../core/constants/theme.dart';
import '../../data/models/prayer_time_model.dart';

class PrayerTimeRow extends StatelessWidget {
  final PrayerTime prayer;

  /// True for the prayer whose time window is currently active (i.e. its
  /// time has passed but the next prayer hasn't started yet). Visually:
  /// background tint + filled dot + bold text + "ŞU AN" badge.
  final bool isActive;

  /// True for the next upcoming prayer (used optionally; default false).
  /// Visually: outlined copper dot + slightly heavier text.
  final bool isNext;

  /// When true the row is rendered with cream text suited for a heritage
  /// (deep emerald) card background.
  final bool onHeritage;

  const PrayerTimeRow({
    super.key,
    required this.prayer,
    this.isActive = false,
    this.isNext = false,
    this.onHeritage = false,
  });

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final base = onHeritage ? AppColors.cream : AppColors.ink;
    final muted =
        onHeritage ? AppColors.creamMuted : AppColors.inkMuted;
    final highlight =
        onHeritage ? AppColors.copperSoft : AppColors.copper;

    final color = (isActive || isNext) ? highlight : base;
    final weight = isActive
        ? FontWeight.w700
        : (isNext ? FontWeight.w600 : FontWeight.w400);

    final Widget dot;
    if (isActive) {
      // Filled copper disc
      dot = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.copper,
          shape: BoxShape.circle,
        ),
      );
    } else if (isNext) {
      // Outlined copper ring
      dot = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.copper, width: 1.5),
        ),
      );
    } else {
      // Muted dot
      dot = Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: muted.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
      );
    }

    final row = Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(width: 12, child: Center(child: dot)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              prayer.name,
              style: bodyFont(
                size: 15,
                color: color,
                weight: weight,
                letterSpacing: 0.4,
              ),
            ),
          ),
          if (isActive) ...[
            const _ActiveBadge(),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            _fmt(prayer.time),
            style: bodyFont(
              size: 15,
              color: color,
              weight: weight,
              letterSpacing: 0.2,
            ).copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    if (!isActive) return row;

    // Active rows get a warm copper-tinted background pill.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.copper.withOpacity(onHeritage ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: row,
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.copper,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'ŞU AN',
        style: bodyFont(
          size: 9,
          color: AppColors.ivory,
          weight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
