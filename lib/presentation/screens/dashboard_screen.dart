import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/datasources/hadith_repository.dart';
import '../../data/datasources/prayer_repository.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/prayer_time_model.dart';
import '../cubits/location_cubit.dart';
import '../widgets/artistic_card.dart';
import '../widgets/platform_aware_button.dart';
import '../widgets/platform_aware_scaffold.dart';
import '../widgets/prayer_time_row.dart';
import 'location_selector_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _fallback = ManualLocation(
    country: 'TR',
    city: 'İstanbul',
    district: 'Üsküdar',
    lat: 41.0233,
    lng: 29.0151,
  );

  @override
  Widget build(BuildContext context) {
    return PlatformAwareScaffold(
      title: 'İrfan Takvimi',
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          final loc = _resolve(state);
          return LayoutBuilder(
            builder: (context, c) {
              final wide = Responsive.isTablet(context) || Responsive.isDesktop(context);
              final content = [
                _LocationHeader(state: state),
                _HadithCard(),
                _PrayerListCard(location: loc),
              ];
              if (!wide) {
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: content,
                );
              }
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(children: [content[0], content[1]])),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: content[2]),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  ManualLocation _resolve(LocationState s) {
    if (s is LocationManualState) return s.location;
    if (s is LocationDenied) return s.fallback;
    return _fallback;
  }
}

class _LocationHeader extends StatelessWidget {
  final LocationState state;
  const _LocationHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final (label, mode) = switch (state) {
      LocationManualState(:final location) =>
        ('${location.district}, ${location.city}', 'Manuel'),
      LocationGpsState(:final location) => (
          '${location.lat.toStringAsFixed(3)}, ${location.lng.toStringAsFixed(3)}',
          'GPS'
        ),
      LocationDenied(:final fallback) =>
        ('${fallback.district}, ${fallback.city}', 'İzin reddedildi'),
      LocationInitial() => ('İstanbul, Üsküdar', 'Varsayılan'),
    };
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LocationSelectorScreen()),
      ),
      child: ArtisticCard(
        child: Row(
          children: [
            const Icon(Icons.place_outlined, color: AppColors.emeraldDeep),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(mode,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repo = context.read<IHadithRepository>();
    final h = repo.getDaily();
    return ArtisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Günün Hadisi',
              style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 1.2,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Text(h.text,
              style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.indigoDeep)),
          const SizedBox(height: AppSpacing.sm),
          Text('— ${h.source}, no. ${h.hadithNo}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _PrayerListCard extends StatelessWidget {
  final ManualLocation location;
  const _PrayerListCard({required this.location});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<IPrayerRepository>();
    return ArtisticCard(
      child: FutureBuilder<DailyPrayerSchedule?>(
        future: repo.getToday(location),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final schedule = snap.data;
          if (schedule == null) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Vakitler alınamadı. İnternet bağlantınızı kontrol edin.',
                style: TextStyle(color: AppColors.indigo),
              ),
            );
          }
          final now = DateTime.now();
          final nextIdx = schedule.prayers.indexWhere((p) => p.time.isAfter(now));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bugünün Vakitleri',
                  style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.2,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < schedule.prayers.length; i++)
                PrayerTimeRow(prayer: schedule.prayers[i], isNext: i == nextIdx),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: PlatformAwareButton(
                  label: 'GPS Konumu Kullan',
                  onPressed: () => context.read<LocationCubit>().enableGps(
                        fallback: DashboardScreen._fallback,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
