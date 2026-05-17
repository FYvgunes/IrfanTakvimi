import 'package:hive/hive.dart';

class AppSettings {
  final bool notificationsEnabled;
  final int gpsDistanceFilterMeters;
  final String languageCode;

  const AppSettings({
    required this.notificationsEnabled,
    required this.gpsDistanceFilterMeters,
    required this.languageCode,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    int? gpsDistanceFilterMeters,
    String? languageCode,
  }) =>
      AppSettings(
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        gpsDistanceFilterMeters:
            gpsDistanceFilterMeters ?? this.gpsDistanceFilterMeters,
        languageCode: languageCode ?? this.languageCode,
      );

  static const defaults = AppSettings(
    notificationsEnabled: true,
    gpsDistanceFilterMeters: 5000,
    languageCode: 'tr',
  );
}

abstract class ISettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class SettingsRepository implements ISettingsRepository {
  static const _boxName = 'settings';
  static const _kNotif = 'notifications_enabled';
  static const _kDistance = 'gps_distance_filter_m';
  static const _kLang = 'language_code';

  late final Box _box;

  Future<void> open() async {
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<AppSettings> load() async => AppSettings(
        notificationsEnabled: _box.get(_kNotif,
            defaultValue: AppSettings.defaults.notificationsEnabled) as bool,
        gpsDistanceFilterMeters: _box.get(_kDistance,
            defaultValue: AppSettings.defaults.gpsDistanceFilterMeters) as int,
        languageCode: _box.get(_kLang,
            defaultValue: AppSettings.defaults.languageCode) as String,
      );

  @override
  Future<void> save(AppSettings s) async {
    await _box.put(_kNotif, s.notificationsEnabled);
    await _box.put(_kDistance, s.gpsDistanceFilterMeters);
    await _box.put(_kLang, s.languageCode);
  }
}
