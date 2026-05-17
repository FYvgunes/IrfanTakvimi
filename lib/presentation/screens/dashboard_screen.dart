import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/theme.dart';
import '../../core/utils/nearest_location.dart';
import '../../core/utils/responsive.dart';
import '../../data/datasources/hadith_repository.dart';
import '../../data/datasources/location_repository.dart';
import '../../data/datasources/prayer_repository.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/prayer_time_model.dart';
import '../cubits/location_cubit.dart';
import '../widgets/artistic_card.dart';
import '../widgets/platform_aware_scaffold.dart';
import '../widgets/prayer_time_row.dart';
import 'location_selector_screen.dart';

const _trMonths = [
  '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];
const _trWeekdays = [
  '', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar',
];

String _formatDate(DateTime d) =>
    '${d.day} ${_trMonths[d.month]} ${d.year} · ${_trWeekdays[d.weekday]}';

String _formatTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _formatClock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'
    ':${t.second.toString().padLeft(2, '0')}';

String _countdown(DateTime target, DateTime now) {
  final d = target.difference(now);
  if (d.isNegative) return 'Vakti geçti';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '$h sa $m dk $s sn kaldı';
  if (m > 0) return '$m dk $s sn kaldı';
  return '$s sn kaldı';
}

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
          final header = _LocationHeader(state: state);
          final prayerCard = _PrayerHeritageCard(location: loc);
          final hadithQuote = const _HadithQuote();

          final wide = Responsive.isTablet(context) || Responsive.isDesktop(context);
          if (!wide) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
              children: [
                header,
                const SizedBox(height: AppSpacing.lg),
                prayerCard,
                const SizedBox(height: AppSpacing.lg),
                hadithQuote,
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              header,
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: prayerCard),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: hadithQuote),
                ],
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
    if (s is LocationGpsState) {
      // Wrap the live GPS coords in a ManualLocation so the prayer
      // repository (which only reads lat/lng) gets the actual position
      // rather than the static fallback.
      return ManualLocation(
        country: 'TR',
        city: 'GPS',
        district: 'GPS',
        lat: s.location.lat,
        lng: s.location.lng,
      );
    }
    return _fallback;
  }
}

class _LocationHeader extends StatefulWidget {
  final LocationState state;
  const _LocationHeader({required this.state});

  @override
  State<_LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends State<_LocationHeader> {
  Timer? _tick;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final (place, mode) = switch (state) {
      LocationManualState(:final location) =>
        (location.district.toUpperCase(), 'Manuel'),
      LocationGpsState(:final location) => _gpsLabel(context, location),
      LocationDenied(:final fallback) =>
        (fallback.district.toUpperCase(), 'İzin reddedildi'),
      LocationInitial() => ('ÜSKÜDAR', 'Varsayılan'),
    };
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LocationSelectorScreen()),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            Text(
              place,
              textAlign: TextAlign.center,
              style: displayFont(
                size: 26,
                weight: FontWeight.w500,
                letterSpacing: 4,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 56,
              height: 1,
              color: AppColors.copper.withOpacity(0.55),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatDate(_now),
              style: bodyFont(
                size: 13,
                color: AppColors.inkMuted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatClock(_now),
              style: displayFont(
                size: 28,
                color: AppColors.ink,
                weight: FontWeight.w500,
                letterSpacing: 2.4,
              ).copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              mode,
              style: bodyFont(
                size: 10,
                color: AppColors.copper,
                letterSpacing: 1.6,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// For GPS state, display the nearest known province name rather than the
/// raw lat/lng. The actual GPS coordinates are still passed downstream to
/// the prayer-time API for precision.
(String, String) _gpsLabel(BuildContext context, GpsLocation g) {
  final repo = context.read<ILocationRepository>();
  final match = nearestLocation(
    lat: g.lat,
    lng: g.lng,
    countries: repo.countries,
  );
  if (match == null) return ('GPS', 'GPS');
  final modeSuffix = match.distanceKm < 1
      ? 'GPS'
      : 'GPS · ~${match.distanceKm.toStringAsFixed(0)} km';
  return (match.city.name.toUpperCase(), modeSuffix);
}

class _PrayerHeritageCard extends StatefulWidget {
  final ManualLocation location;
  const _PrayerHeritageCard({required this.location});

  @override
  State<_PrayerHeritageCard> createState() => _PrayerHeritageCardState();
}

class _PrayerHeritageCardState extends State<_PrayerHeritageCard> {
  Timer? _tick;
  DateTime _now = DateTime.now();
  Future<DailyPrayerSchedule?>? _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<IPrayerRepository>().getToday(widget.location);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void didUpdateWidget(covariant _PrayerHeritageCard old) {
    super.didUpdateWidget(old);
    if (old.location != widget.location) {
      _future = context.read<IPrayerRepository>().getToday(widget.location);
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ArtisticCard(
      variant: CardVariant.heritage,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: FutureBuilder<DailyPrayerSchedule?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.copperSoft),
              ),
            );
          }
          final schedule = snap.data;
          if (schedule == null) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Vakitler alınamadı. İnternet bağlantınızı kontrol edin.',
                style: bodyFont(color: AppColors.cream),
              ),
            );
          }
          final now = _now;
          final nextIdx = schedule.prayers.indexWhere((p) => p.time.isAfter(now));
          // The active prayer is the most recent one whose time has passed;
          // -1 means we're before the day's first prayer (Fajr).
          final activeIdx = schedule.prayers
              .lastIndexWhere((p) => !p.time.isAfter(now));
          final next = nextIdx >= 0 ? schedule.prayers[nextIdx] : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NextPrayerHero(next: next, now: now),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 1,
                color: AppColors.copper.withOpacity(0.30),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'BUGÜNÜN VAKİTLERİ',
                style: bodyFont(
                  size: 11,
                  color: AppColors.copperSoft,
                  weight: FontWeight.w600,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              for (var i = 0; i < schedule.prayers.length; i++)
                PrayerTimeRow(
                  prayer: schedule.prayers[i],
                  isActive: i == activeIdx,
                  onHeritage: true,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NextPrayerHero extends StatelessWidget {
  final PrayerTime? next;
  final DateTime now;
  const _NextPrayerHero({required this.next, required this.now});

  @override
  Widget build(BuildContext context) {
    if (next == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIRADAKİ',
            style: bodyFont(
              size: 10,
              color: AppColors.copperSoft,
              letterSpacing: 2.4,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tüm vakitler tamamlandı',
            style: displayFont(size: 22, color: AppColors.cream),
          ),
        ],
      );
    }
    final n = next!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SIRADAKİ',
              style: bodyFont(
                size: 10,
                color: AppColors.copperSoft,
                letterSpacing: 2.4,
                weight: FontWeight.w600,
              ),
            ),
            Text(
              _formatClock(now),
              style: bodyFont(
                size: 12,
                color: AppColors.creamMuted,
                letterSpacing: 1.0,
                weight: FontWeight.w500,
              ).copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              n.name,
              style: displayFont(
                size: 32,
                color: AppColors.cream,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              _formatTime(n.time),
              style: displayFont(
                size: 36,
                color: AppColors.copperSoft,
                letterSpacing: 1.0,
              ).copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _countdown(n.time, now),
          style: bodyFont(
            size: 13,
            color: AppColors.creamMuted,
            letterSpacing: 0.4,
          ).copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _HadithQuote extends StatelessWidget {
  const _HadithQuote();

  @override
  Widget build(BuildContext context) {
    final repo = context.read<IHadithRepository>();
    final HadithModel h = repo.getDaily();
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GÜNÜN HADİSİ',
            style: bodyFont(
              size: 10,
              color: AppColors.copper,
              weight: FontWeight.w600,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(width: 40, height: 1, color: AppColors.copper.withOpacity(0.55)),
          const SizedBox(height: AppSpacing.md),
          Text(
            '“${h.text}”',
            style: displayFont(
              size: 20,
              color: AppColors.ink,
              weight: FontWeight.w400,
            ).copyWith(fontStyle: FontStyle.italic, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '— ${h.source}, no. ${h.hadithNo}',
            style: bodyFont(
              size: 12,
              color: AppColors.inkMuted,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

