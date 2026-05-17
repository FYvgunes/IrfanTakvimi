import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/theme.dart';
import '../../data/datasources/location_repository.dart';
import '../../data/models/location_model.dart';
import '../cubits/location_cubit.dart';
import '../widgets/artistic_card.dart';
import '../widgets/picker.dart';
import '../widgets/platform_aware_button.dart';
import '../widgets/platform_aware_scaffold.dart';

class LocationSelectorScreen extends StatefulWidget {
  const LocationSelectorScreen({super.key});

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  CountryEntry? _country;
  CityEntry? _city;
  DistrictEntry? _district;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ILocationRepository>();
    final countries = repo.countries;
    _country ??= countries.isNotEmpty ? countries.first : null;

    final cities = _country?.cities ?? const <CityEntry>[];
    final districts = _city?.districts ?? const <DistrictEntry>[];
    final showCountry = countries.length > 1;

    return PlatformAwareScaffold(
      title: 'Konum Seç',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ArtisticCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KONUM',
                style: bodyFont(
                  size: 11,
                  color: AppColors.copper,
                  weight: FontWeight.w600,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                  width: 40,
                  height: 1,
                  color: AppColors.copper.withOpacity(0.55)),
              const SizedBox(height: AppSpacing.lg),
              if (showCountry) ...[
                PickerField(
                  label: 'Ülke',
                  value: _country?.name,
                  onTap: () async {
                    final picked = await showPicker<CountryEntry>(
                      context: context,
                      title: 'Ülke Seç',
                      items: countries,
                      labelOf: (c) => c.name,
                      selected: _country,
                    );
                    if (picked != null) {
                      setState(() {
                        _country = picked;
                        _city = null;
                        _district = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              PickerField(
                label: 'İl',
                value: _city?.name,
                onTap: cities.isEmpty
                    ? null
                    : () async {
                        final picked = await showPicker<CityEntry>(
                          context: context,
                          title: 'İl Seç',
                          items: cities,
                          labelOf: (c) => c.name,
                          selected: _city,
                        );
                        if (picked != null) {
                          setState(() {
                            _city = picked;
                            _district = null;
                          });
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.md),
              PickerField(
                label: 'İlçe',
                value: _district?.name,
                placeholder: _city == null ? 'Önce il seçin' : 'Seç',
                onTap: districts.isEmpty
                    ? null
                    : () async {
                        final picked = await showPicker<DistrictEntry>(
                          context: context,
                          title: '${_city!.name} • İlçe',
                          items: districts,
                          labelOf: (d) => d.name,
                          selected: _district,
                        );
                        if (picked != null) {
                          setState(() => _district = picked);
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerRight,
                child: PlatformAwareButton(
                  label: 'Kaydet',
                  onPressed: _canSave ? _save : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canSave =>
      _country != null && _city != null && _district != null;

  void _save() {
    final loc = ManualLocation(
      country: _country!.code,
      city: _city!.name,
      district: _district!.name,
      lat: _district!.lat,
      lng: _district!.lng,
    );
    context.read<LocationCubit>().setManual(loc);
    Navigator.of(context).pop();
  }
}
