import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/theme.dart';
import '../../data/datasources/location_repository.dart';
import '../../data/models/location_model.dart';
import '../cubits/location_cubit.dart';
import '../widgets/artistic_card.dart';
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
    _city ??= cities.isNotEmpty ? cities.first : null;
    final districts = _city?.districts ?? const <DistrictEntry>[];
    _district ??= districts.isNotEmpty ? districts.first : null;

    return PlatformAwareScaffold(
      title: 'Konum Seç',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ArtisticCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ülke / İl / İlçe',
                  style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.2,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.md),
              _Dropdown<CountryEntry>(
                label: 'Ülke',
                value: _country,
                items: countries,
                itemLabel: (c) => c.name,
                onChanged: (c) => setState(() {
                  _country = c;
                  _city = null;
                  _district = null;
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              _Dropdown<CityEntry>(
                label: 'İl',
                value: _city,
                items: cities,
                itemLabel: (c) => c.name,
                onChanged: (c) => setState(() {
                  _city = c;
                  _district = null;
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              _Dropdown<DistrictEntry>(
                label: 'İlçe',
                value: _district,
                items: districts,
                itemLabel: (d) => d.name,
                onChanged: (d) => setState(() => _district = d),
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

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e))))
              .toList(growable: false),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}
