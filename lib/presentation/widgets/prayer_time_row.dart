import 'package:flutter/material.dart';

import '../../core/constants/theme.dart';
import '../../data/models/prayer_time_model.dart';

class PrayerTimeRow extends StatelessWidget {
  final PrayerTime prayer;
  final bool isNext;

  const PrayerTimeRow({
    super.key,
    required this.prayer,
    this.isNext = false,
  });

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final color = isNext ? AppColors.emeraldDeep : AppColors.indigoDeep;
    final weight = isNext ? FontWeight.w700 : FontWeight.w500;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isNext ? AppColors.gold : AppColors.muted.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              prayer.name,
              style: TextStyle(color: color, fontWeight: weight, fontSize: 16),
            ),
          ),
          Text(
            _fmt(prayer.time),
            style: TextStyle(
              color: color,
              fontWeight: weight,
              fontSize: 16,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
