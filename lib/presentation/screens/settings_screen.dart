import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/theme.dart';
import '../../data/datasources/settings_repository.dart';
import '../cubits/settings_cubit.dart';
import '../widgets/artistic_card.dart';
import '../widgets/platform_aware_scaffold.dart';
import 'location_selector_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _distanceOptions = <int>[1000, 5000, 10000, 25000];
  static const _languageOptions = <String>['tr', 'en', 'ar'];

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return PlatformAwareScaffold(
      title: s.t('settings_title'),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _SectionLabel(s.t('section_notifications')),
              ArtisticCard(
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.t('notif_title')),
                  subtitle: Text(s.t('notif_subtitle')),
                  value: settings.notificationsEnabled,
                  activeColor: AppColors.emeraldDeep,
                  onChanged: (v) =>
                      context.read<SettingsCubit>().setNotificationsEnabled(v),
                ),
              ),
              _SectionLabel(s.t('section_location')),
              ArtisticCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined,
                      color: AppColors.emeraldDeep),
                  title: Text(s.t('select_manual_location')),
                  subtitle: Text(s.t('select_manual_location_sub')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LocationSelectorScreen(),
                    ),
                  ),
                ),
              ),
              ArtisticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.t('gps_threshold_title'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.indigoDeep)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(s.t('gps_threshold_sub'),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: settings.gpsDistanceFilterMeters,
                      items: _distanceOptions
                          .map((m) => DropdownMenuItem<int>(
                                value: m,
                                child: Text(_formatDistance(m)),
                              ))
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v != null) {
                          context.read<SettingsCubit>().setGpsDistanceFilter(v);
                        }
                      },
                    ),
                  ],
                ),
              ),
              _SectionLabel(s.t('section_language')),
              ArtisticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.t('language_picker_label'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.indigoDeep)),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: settings.languageCode,
                      items: _languageOptions
                          .map((code) => DropdownMenuItem<String>(
                                value: code,
                                child: Text(s.t('lang_$code')),
                              ))
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v != null) {
                          context.read<SettingsCubit>().setLanguage(v);
                        }
                      },
                    ),
                  ],
                ),
              ),
              _SectionLabel(s.t('section_about')),
              ArtisticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.t('about_app'),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emeraldDeep)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(s.t('about_version'),
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(s.t('about_credit'),
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, height: 1.4)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDistance(int m) =>
      m >= 1000 ? '${(m / 1000).toStringAsFixed(0)} km' : '$m m';
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.xs),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              color: AppColors.gold,
              fontWeight: FontWeight.w700)),
    );
  }
}
