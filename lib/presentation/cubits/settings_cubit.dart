import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/settings_repository.dart';

class SettingsCubit extends Cubit<AppSettings> {
  final ISettingsRepository _repo;

  SettingsCubit(this._repo, AppSettings initial) : super(initial);

  static Future<SettingsCubit> create(ISettingsRepository repo) async {
    final initial = await repo.load();
    return SettingsCubit(repo, initial);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final next = state.copyWith(notificationsEnabled: enabled);
    emit(next);
    await _repo.save(next);
  }

  Future<void> setGpsDistanceFilter(int meters) async {
    final next = state.copyWith(gpsDistanceFilterMeters: meters);
    emit(next);
    await _repo.save(next);
  }

  Future<void> setLanguage(String code) async {
    final next = state.copyWith(languageCode: code);
    emit(next);
    await _repo.save(next);
  }

  /// [mode] must be one of 'system' | 'light' | 'dark'.
  Future<void> setThemeMode(String mode) async {
    final next = state.copyWith(themeMode: mode);
    emit(next);
    await _repo.save(next);
  }
}
