import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/theme.dart';
import '../../data/datasources/prayer_repository.dart';
import '../../data/datasources/religious_day_repository.dart';
import '../../data/models/location_model.dart';
import '../../data/models/prayer_time_model.dart';
import '../../data/models/religious_day_model.dart';
import '../cubits/location_cubit.dart';
import '../widgets/artistic_card.dart';
import '../widgets/month_grid.dart';
import '../widgets/platform_aware_scaffold.dart';
import '../widgets/prayer_time_row.dart';

const _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];
const _monthShort = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  static const _fallback = ManualLocation(
    country: 'TR',
    city: 'İstanbul',
    district: 'Üsküdar',
    lat: 41.0233,
    lng: 29.0151,
  );

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selected;
  late final DateTime _today;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selected = _today;
    _visibleMonth = DateTime(now.year, now.month);
  }

  Future<void> _openMonthYearPicker() async {
    final p = context.palette;
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: p.ground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (_) => _MonthYearPickerSheet(initial: _visibleMonth),
    );
    if (picked != null && mounted) {
      setState(() => _visibleMonth = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final religiousRepo = context.read<IReligiousDayRepository>();
    final monthDays = religiousRepo.byMonth(_visibleMonth.year, _visibleMonth.month);
    final markedDays = monthDays.map((d) => d.date.day).toSet();
    final selectedReligious = religiousRepo.byDate(_selected);

    return PlatformAwareScaffold(
      title: 'Takvim',
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          final loc = _resolve(state);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ArtisticCard(
                child: Column(
                  children: [
                    _MonthHeader(
                      label: '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                      onPrev: () => setState(() {
                        _visibleMonth = DateTime(
                            _visibleMonth.year, _visibleMonth.month - 1);
                      }),
                      onNext: () => setState(() {
                        _visibleMonth = DateTime(
                            _visibleMonth.year, _visibleMonth.month + 1);
                      }),
                      onLabelTap: _openMonthYearPicker,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    MonthGrid(
                      month: _visibleMonth,
                      selected: _selected,
                      today: _today,
                      onDayTap: (d) => setState(() => _selected = d),
                      markedDays: markedDays,
                    ),
                  ],
                ),
              ),
              _SelectedDayCard(
                date: _selected,
                location: loc,
                religious: selectedReligious,
              ),
            ],
          );
        },
      ),
    );
  }

  ManualLocation _resolve(LocationState s) {
    if (s is LocationManualState) return s.location;
    if (s is LocationDenied) return s.fallback;
    return CalendarScreen._fallback;
  }
}

class _MonthHeader extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onLabelTap;

  const _MonthHeader({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.onLabelTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: p.heritageEdge),
          onPressed: onPrev,
        ),
        Expanded(
          child: InkWell(
            onTap: onLabelTap,
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: p.copper.withOpacity(0.75),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: p.heritageEdge),
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _MonthYearPickerSheet extends StatefulWidget {
  final DateTime initial;
  const _MonthYearPickerSheet({required this.initial});

  @override
  State<_MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<_MonthYearPickerSheet> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final currentYear = DateTime.now().year;
    // Years span 5 back and 10 forward — enough for past records and planning.
    final years = [for (var y = currentYear - 5; y <= currentYear + 10; y++) y];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: p.copper.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'YIL',
              textAlign: TextAlign.center,
              style: bodyFont(
                size: 11,
                color: p.copper,
                weight: FontWeight.w600,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: years.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final y = years[i];
                  final selected = y == _year;
                  return ChoiceChip(
                    label: Text('$y'),
                    selected: selected,
                    onSelected: (_) => setState(() => _year = y),
                    backgroundColor: p.groundSoft,
                    selectedColor: p.heritage,
                    side: BorderSide(color: p.copper.withOpacity(0.40)),
                    labelStyle: bodyFont(
                      size: 14,
                      color: selected ? p.cream : p.ink,
                      weight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'AY',
              textAlign: TextAlign.center,
              style: bodyFont(
                size: 11,
                color: p.copper,
                weight: FontWeight.w600,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 2.4,
              children: [
                for (var m = 1; m <= 12; m++)
                  _MonthChip(
                    label: _monthShort[m - 1],
                    selected: m == widget.initial.month && _year == widget.initial.year,
                    onTap: () =>
                        Navigator.of(context).pop(DateTime(_year, m)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MonthChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? p.heritage : p.groundSoft,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: p.copper.withOpacity(selected ? 0.75 : 0.30),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: bodyFont(
            size: 14,
            color: selected ? p.cream : p.ink,
            weight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  final DateTime date;
  final ManualLocation location;
  final ReligiousDay? religious;

  const _SelectedDayCard({
    required this.date,
    required this.location,
    required this.religious,
  });

  static const _weekdayNames = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar',
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final repo = context.read<IPrayerRepository>();
    final weekday = _weekdayNames[date.weekday - 1];
    return ArtisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${date.day} · $weekday',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 1.2,
              color: p.copper,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (religious != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _ReligiousDayBanner(day: religious!),
          ],
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<DailyPrayerSchedule>>(
            future: repo.getMonth(location, DateTime(date.year, date.month)),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final month = snap.data ?? const <DailyPrayerSchedule>[];
              final schedule = month.cast<DailyPrayerSchedule?>().firstWhere(
                    (s) =>
                        s != null &&
                        s.date.year == date.year &&
                        s.date.month == date.month &&
                        s.date.day == date.day,
                    orElse: () => null,
                  );
              if (schedule == null) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Vakitler alınamadı.',
                    style: TextStyle(color: p.ink),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final p in schedule.prayers) PrayerTimeRow(prayer: p),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReligiousDayBanner extends StatelessWidget {
  final ReligiousDay day;
  const _ReligiousDayBanner({required this.day});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: p.copper.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: p.copper.withOpacity(0.50), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.copper,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.name,
                  style: displayFont(
                    size: 16,
                    color: p.ink,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  day.hijri,
                  style: bodyFont(
                    size: 11,
                    color: p.inkMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
