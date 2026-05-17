import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/theme.dart';
import 'core/services/compass_service.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'data/datasources/esma_repository.dart';
import 'data/datasources/hadith_repository.dart';
import 'data/datasources/location_repository.dart';
import 'data/datasources/prayer_repository.dart';
import 'data/datasources/religious_day_repository.dart';
import 'data/datasources/settings_repository.dart';
import 'presentation/cubits/location_cubit.dart';
import 'presentation/cubits/settings_cubit.dart';
import 'presentation/screens/calendar_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/hadith_list_screen.dart';
import 'presentation/screens/qibla_compass_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/app_logo.dart';
import 'presentation/widgets/platform_aware_nav_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final hadithCache = await HadithRepository.openBox();
  final hadithRepo = HadithRepository(cache: hadithCache);
  await hadithRepo.load();

  final locationRepo = LocationRepository();
  await locationRepo.load();

  final religiousDayRepo = ReligiousDayRepository();
  await religiousDayRepo.load();

  final esmaRepo = EsmaRepository();
  await esmaRepo.load();

  final settingsRepo = SettingsRepository();
  await settingsRepo.open();
  final settingsCubit = await SettingsCubit.create(settingsRepo);

  final notifications = NotificationService();
  await notifications.init();

  final prayerCache = await PrayerRepository.openBox();

  runApp(IrfanTakvimApp(
    locationService: LocationService(),
    compassService: CompassService(),
    hadithRepository: hadithRepo,
    locationRepository: locationRepo,
    prayerRepository: PrayerRepository(cache: prayerCache),
    religiousDayRepository: religiousDayRepo,
    esmaRepository: esmaRepo,
    settingsRepository: settingsRepo,
    settingsCubit: settingsCubit,
    notificationService: notifications,
  ));
}

class IrfanTakvimApp extends StatelessWidget {
  final ILocationService locationService;
  final ICompassService compassService;
  final IHadithRepository hadithRepository;
  final ILocationRepository locationRepository;
  final IPrayerRepository prayerRepository;
  final IReligiousDayRepository religiousDayRepository;
  final IEsmaRepository esmaRepository;
  final ISettingsRepository settingsRepository;
  final SettingsCubit settingsCubit;
  final INotificationService notificationService;

  const IrfanTakvimApp({
    super.key,
    required this.locationService,
    required this.compassService,
    required this.hadithRepository,
    required this.locationRepository,
    required this.prayerRepository,
    required this.religiousDayRepository,
    required this.esmaRepository,
    required this.settingsRepository,
    required this.settingsCubit,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ILocationService>.value(value: locationService),
        RepositoryProvider<ICompassService>.value(value: compassService),
        RepositoryProvider<IHadithRepository>.value(value: hadithRepository),
        RepositoryProvider<ILocationRepository>.value(value: locationRepository),
        RepositoryProvider<IPrayerRepository>.value(value: prayerRepository),
        RepositoryProvider<IReligiousDayRepository>.value(value: religiousDayRepository),
        RepositoryProvider<IEsmaRepository>.value(value: esmaRepository),
        RepositoryProvider<ISettingsRepository>.value(value: settingsRepository),
        RepositoryProvider<INotificationService>.value(value: notificationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LocationCubit(locationService)),
          BlocProvider.value(value: settingsCubit),
        ],
        child: BlocBuilder<SettingsCubit, AppSettings>(
          builder: (context, settings) {
            final strings = AppStrings(settings.languageCode);
            return MaterialApp(
              title: 'İrfan Takvimi',
              debugShowCheckedModeBanner: false,
              theme: buildAppTheme(Brightness.light),
              darkTheme: buildAppTheme(Brightness.dark),
              themeMode: switch (settings.themeMode) {
                'light' => ThemeMode.light,
                'dark' => ThemeMode.dark,
                _ => ThemeMode.system,
              },
              locale: Locale(settings.languageCode),
              supportedLocales: AppStrings.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: PlatformAwareNavShell(
                destinations: [
                  NavDestination(
                    icon: Icons.wb_sunny_outlined,
                    selectedIcon: Icons.wb_sunny,
                    label: strings.t('tab_today'),
                    customIcon: const AppLogo(size: 24),
                    builder: (_) => const DashboardScreen(),
                  ),
                  NavDestination(
                    icon: Icons.calendar_month_outlined,
                    selectedIcon: Icons.calendar_month,
                    label: strings.t('tab_calendar'),
                    builder: (_) => const CalendarScreen(),
                  ),
                  NavDestination(
                    icon: Icons.explore_outlined,
                    selectedIcon: Icons.explore,
                    label: strings.t('tab_qibla'),
                    builder: (_) => const QiblaCompassScreen(),
                  ),
                  NavDestination(
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book,
                    label: strings.t('tab_hadiths'),
                    builder: (_) => const HadithListScreen(),
                  ),
                  NavDestination(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: strings.t('tab_settings'),
                    builder: (_) => const SettingsScreen(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
