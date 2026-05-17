import 'package:flutter/material.dart';

import '../../core/constants/theme.dart';

class MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onDayTap;

  /// Days within [month] that should render a small copper marker dot below
  /// the day number — typically religious days. Compared by day-of-month.
  final Set<int> markedDays;

  const MonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.today,
    required this.onDayTap,
    this.markedDays = const {},
  });

  static const _weekdayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
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
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: p.inkMuted,
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
                Expanded(child: _buildCell(p, r * 7 + c, leading, daysInMonth)),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(AppPalette p, int index, int leading, int daysInMonth) {
    final dayNum = index - leading + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());
    }
    final date = DateTime(month.year, month.month, dayNum);
    final isToday = _sameDay(date, today);
    final isSelected = _sameDay(date, selected);
    final isMarked = markedDays.contains(dayNum);

    // Background fill priority: selected > marked tint > none.
    final Color? bgColor = isSelected
        ? p.heritage
        : (isMarked ? p.copper.withOpacity(0.18) : null);

    final Border? border = isSelected
        ? null
        : isToday
            ? Border.all(color: p.copper, width: 1.5)
            : isMarked
                ? Border.all(
                    color: p.copper.withOpacity(0.55),
                    width: 1,
                  )
                : null;

    final Color textColor = isSelected
        ? p.cream
        : isMarked
            ? p.copper
            : isToday
                ? p.heritage
                : p.ink;

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
                color: bgColor,
                border: border,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$dayNum',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isSelected || isToday || isMarked
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  if (isMarked)
                    Positioned(
                      bottom: 3,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? p.copperSoft : p.copper,
                        ),
                      ),
                    ),
                ],
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
