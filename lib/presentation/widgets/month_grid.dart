import 'package:flutter/material.dart';

import '../../core/constants/theme.dart';

class MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onDayTap;

  const MonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.today,
    required this.onDayTap,
  });

  static const _weekdayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = (first.weekday + 6) % 7;
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final l in _weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(child: _buildCell(r * 7 + c, leading, daysInMonth)),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(int index, int leading, int daysInMonth) {
    final dayNum = index - leading + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());
    }
    final date = DateTime(month.year, month.month, dayNum);
    final isToday = _sameDay(date, today);
    final isSelected = _sameDay(date, selected);

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => onDayTap(date),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.emeraldDeep : null,
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.gold, width: 1.5)
                    : null,
              ),
              child: Text(
                '$dayNum',
                style: TextStyle(
                  color: isSelected
                      ? AppColors.parchment
                      : (isToday ? AppColors.emeraldDeep : AppColors.indigoDeep),
                  fontWeight:
                      isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
