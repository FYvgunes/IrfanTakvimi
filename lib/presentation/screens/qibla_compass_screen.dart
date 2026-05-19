import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/theme.dart';
import '../../core/services/compass_service.dart';
import '../../core/utils/qibla_calculator.dart';
import '../../data/models/location_model.dart';
import '../cubits/location_cubit.dart';
import '../widgets/artistic_card.dart';
import '../widgets/platform_aware_scaffold.dart';
import '../widgets/qibla_compass.dart';

class QiblaCompassScreen extends StatelessWidget {
  const QiblaCompassScreen({super.key});

  static const _fallback = ManualLocation(
    country: 'TR',
    city: 'İstanbul',
    district: 'Üsküdar',
    lat: 41.0233,
    lng: 29.0151,
  );

  @override
  Widget build(BuildContext context) {
    final compass = context.read<ICompassService>();
    return PlatformAwareScaffold(
      title: 'Kıble',
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          final loc = _resolveLatLng(state);
          final bearing = QiblaCalculator.bearing(lat: loc.$1, lng: loc.$2);

          if (!compass.isSupported) {
            return _UnsupportedFallback(bearingDegrees: bearing);
          }

          return StreamBuilder<double>(
            stream: compass.headingStream(),
            builder: (context, snap) {
              final p = context.palette;
              final heading = snap.data ?? 0;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ArtisticCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Kâbe Yönü',
                            style: TextStyle(
                                fontSize: 13,
                                letterSpacing: 1.2,
                                color: p.copper,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.md),
                        QiblaCompass(
                          headingDegrees: heading,
                          qiblaBearingDegrees: bearing,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Yön: ${bearing.toStringAsFixed(1)}°',
                            style: TextStyle(
                                color: p.ink, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  (double, double) _resolveLatLng(LocationState s) => switch (s) {
        LocationManualState(:final location) => (location.lat, location.lng),
        LocationGpsState(:final location) => (location.lat, location.lng),
        LocationDenied(:final fallback) => (fallback.lat, fallback.lng),
        LocationInitial() => (_fallback.lat, _fallback.lng),
      };
}

class _UnsupportedFallback extends StatelessWidget {
  final double bearingDegrees;
  const _UnsupportedFallback({required this.bearingDegrees});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: ArtisticCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: p.copper, size: 36),
            const SizedBox(height: AppSpacing.sm),
            Text('Bu platformda pusula sensörü yok.',
                style: TextStyle(color: p.ink)),
            const SizedBox(height: AppSpacing.sm),
            Text('Kâbe yönü: ${bearingDegrees.toStringAsFixed(1)}° (kuzeyden)',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: p.copper)),
          ],
        ),
      ),
    );
  }
}
