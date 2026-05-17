import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/theme.dart';
import '../../data/datasources/prayer_repository.dart';
import '../../data/models/location_model.dart';
import '../../data/models/prayer_time_model.dart';
import '../cubits/location_cubit.dart';
import '../widgets/artistic_card.dart';
import '../widgets/month_grid.dart';
import '../widgets/platform_aware_scaffold.dart';
import '../widgets/prayer_time_row.dart';

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

  static const _monthNames = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selected = _today;
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
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
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    MonthGrid(
                      month: _visibleMonth,
                      selected: _selected,
                      today: _today,
                      onDayTap: (d) => setState(() => _selected = d),
                    ),
                  ],
                ),
              ),
              _SelectedDayCard(date: _selected, location: loc),
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

  const _MonthHeader({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.emeraldDeep),
          onPressed: onPrev,
        ),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.indigoDeep,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.emeraldDeep),
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  final DateTime date;
  final ManualLocation location;

  const _SelectedDayCard({required this.date, required this.location});

  static const _weekdayNames = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar',
  ];

  @override
  Widget build(BuildContext context) {
    final repo = context.read<IPrayerRepository>();
    final weekday = _weekdayNames[date.weekday - 1];
    return ArtisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${date.day} · $weekday',
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: 1.2,
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
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
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Vakitler alınamadı.',
                    style: TextStyle(color: AppColors.indigoDeep),
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
