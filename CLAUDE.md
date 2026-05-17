# Project Specification: İrfan Takvimi (Spiritual & Artistic Calendar App)

## 1. Project Core & Constraints
* **Goal:** A cross-platform mobile calendar app combining accurate prayer times, location-based Qibla finder, and authentic daily spiritual notifications.
* **Location Dynamism:** The app must support location configuration via user selection (Country, City, District) OR dynamic updates based on GPS. Location tracking must dynamically update the active prayer matrix as the user travels.
* **Privacy Guardrail:** Hardware location access must explicitly prompt the user for permission. If denied, the app gracefully falls back to the manually selected City/District parameters.
* **Design Aesthetic:** Minimalist, artistic, and spiritual UI. Uses a premium color palette (emerald greens, cream/parchment backgrounds, deep indigo text) with elegant typography and subtle Islamic geometric vector paths.
* **Content Guardrail (Strict):** ZERO-tolerance for unverified, weak, or fabricated (*mawdu'*) Hadiths. The system must strictly pull content from verified sources, explicitly prioritizing *Riyad as-Salihin*.
* **Token Optimization Rule:** Focus heavily on clean, modular architectural design pattern templates. Do not allow the AI model to output repetitive UI layout blocks or hardcoded textual datasets within the core codebase.

---

## 2. Technical Architecture & Tech Stack

### 2.1. Framework Selection
* **Cross-Platform Core:** Flutter (Dart) or React Native (TypeScript). *Standardized preference: Flutter for high-performance custom canvas drawing (Qibla compass) and ultra-smooth UI animations.*
* **State Management:** Clean, minimal boilerplates (Cubit/Bloc for Flutter, or Zustand for React Native) to manage reactive location states.
* **Local Caching Database:** Hive (NoSQL, lightning-fast key-value pairing) or SQLite to cache selected city/district structures and coordinate offsets.

### 2.2. Directory Structure (Clean Architecture Pattern)
```text
lib/
├── core/
│   ├── constants/        # theme.dart, app_strings.dart (i18n)
│   ├── services/         # location_service, compass_service, notification_service
│   └── utils/            # qibla_calculator, responsive
├── data/
│   ├── models/           # location_model (sealed), prayer_time_model, hadith_model
│   └── datasources/      # hadith_repository, location_repository, prayer_repository, settings_repository
└── presentation/
    ├── cubits/           # location_cubit (sealed state), settings_cubit
    ├── screens/          # dashboard, calendar, qibla_compass, location_selector,
    │                     # hadith_list, hadith_detail, settings
    └── widgets/          # artistic_card, platform_aware_{scaffold,button,nav_shell},
                          # permission_gate, prayer_time_row, qibla_compass, month_grid

data/datasources/aladhan_client.dart  # Aladhan API client (Diyanet, method=13)
```

---

## 3. High-Efficiency Feature Engineering

### 3.1. Dynamic Location & Permission Architecture
To minimize token consumption, use a unified workflow to handle location states:
* **Permission Request Handler:** Wraps `geolocator` or `permission_handler`. Requests permission at runtime.
* **Dual-Mode Data Source:**
  * *Manual Mode:* User selects Country -> City (İl) -> District (İlçe) from local/remote structural list.
  * *Dynamic GPS Mode:* App listens to background location change streams (using a distance filter threshold, e.g., 5km). If a significant coordinate change is detected, recalculate or fetch new prayer data automatically.

### 3.2. Hadith Management System (Token & Storage Optimized)
To prevent context overflow and token bloat, **never hardcode text arrays** in the source logic. Content is decoupled into an asset-level JSON schema.

```json
[
  {
    "id": 1,
    "text": "Ameller niyetlere göredir...",
    "source": "Riyad as-Salihin",
    "hadith_no": 1
  }
]
```

* **Repository Logic:** Load the structural JSON file on app initialization into local memory.
* **Notification Payload Worker:** Select items sequentially or using a daily deterministic pseudo-random index linked to the Unix epoch timestamp.

### 3.3. Prayer Times Engine & Notification Pipeline
* **Data source:** Aladhan API (`api.aladhan.com/v1/calendar`) with `method=13` (Diyanet İşleri Başkanlığı) and `school=1` (Hanafi Asr). Matches Diyanet's published Turkey times within ±1–2 dk (rounding differences only).
* **Caching:** Monthly response cached in Hive box `prayer_cache`, keyed by `lat,lng,year-MM` with coordinates rounded to 4 decimals (~100 m). Envelope shape: `{"cachedAt": ISO, "data": [...]}`.
* **TTL:** 30 days for the current and future months. Past months never expire (historical / immutable astronomical data). Configurable via `PrayerRepository(ttl: ...)`.
* **Offline / error behavior:** Stale-while-error — when a refresh attempt fails, expired cached data is returned rather than empty. When there is no cache at all and fetch fails, `getMonth` returns `[]` and `getToday` returns `null`; UI shows a "vakitler alınamadı" message instead of fake times.
* **Notification Scheduling:**
    * Trigger 5 local background workers corresponding to daily prayer times.
    * Inject the pre-validated JSON Hadith string directly into the dynamic background notification payload.

### 3.4. Core Math: Qibla Compass Service
* **Hardware Hooks:** Stream data vectors from device Magnetometer and Accelerometer.
* **Great-Circle Distance Vector Formula:**
    Calculate bearing angle $\theta$ from user's active location $(\phi_1, \lambda_1)$ to the holy Kaaba coordinates $(\phi_2, \lambda_2) = (21.4225^\circ\text{ N}, 39.8262^\circ\text{ E})$:

    $$\theta = \operatorname{atan2}\left(\sin(\Delta\lambda)\cdot\cos(\phi_2), \,\cos(\phi_1)\cdot\sin(\phi_2) - \sin(\phi_1)\cdot\cos(\phi_2)\cdot\cos(\Delta\lambda)\right)$$

    *Where $\Delta\lambda = \lambda_2 - \lambda_1$.*
* **UI Rendering:** Pass the dynamic filtered angle matrix into a single custom-painted responsive layout element.

---

## 4. AI Copilot Prompting Guardrails

When feeding tasks into Cursor / Claude / Copilot based on this document, enforce these strict instructions to save context and budget:

1.  **Strict Scaffold-Only Mode:** Generate only structural abstract interfaces, base state management handlers (LocationState with `Manual` and `GPS` variations), and pure logic utilities. Do not expand complex nested multi-line layout containers.
2.  **No Mock Bloat:** Limit fake mock location lists (City/District data) to a maximum of 2 sample items (e.g., Istanbul -> Uskudar). Never generate huge sample data files.
3.  **Global Theme Inheritance:** Write exactly one global reusable styling container (`ArtisticCard`) that handles borders, shadows, backgrounds, and padding uniformly. Every custom card feature must inherit directly from this structure.

---

## 5. Implemented Features (Living Log)

> This section is updated after every addition/change so AI tools always have the current state.

### 5.1. Core / Infra
* `theme.dart` — Emerald/parchment/indigo palette + Material 3 theme builder
* `qibla_calculator.dart` — pure `bearing(lat, lng)` using atan2 formula (Kaaba constants)
* `responsive.dart` — `Breakpoints` (600/1024) + `Responsive.isMobile/Tablet/Desktop/value()` helpers
* `location_service.dart` — `ILocationService`, GPS permission flow + distance-filtered stream
* `compass_service.dart` — `ICompassService`, hardware-supported flag + heading stream (graceful empty on web/desktop)
* `notification_service.dart` — `INotificationService`, 5-prayer local schedule injecting verified Hadith payload (no-op on unsupported platforms)

### 5.2. Data Layer
* `LocationModel` sealed: `ManualLocation | GpsLocation`
* `HadithModel`, `PrayerTime`, `DailyPrayerSchedule`
* `HadithRepository` — loads `assets/data/hadiths.json`, deterministic daily picker via Unix epoch; `getAll()` exposes full list for browsing
* `LocationRepository` — loads `assets/data/locations.json` (Country → City → District tree)
* `AladhanClient` — thin `http` wrapper around `api.aladhan.com/v1/calendar` with `method=13` (Diyanet) and `school=1` (Hanafi Asr). Parses monthly response → `List<DailyPrayerSchedule>`. Maps Aladhan `Fajr` → "İmsak" for TR convention.
* `PrayerRepository` — Aladhan-backed + Hive cache box `prayer_cache`. `getMonth` is cache-first (key: `lat,lng,year-MM`, 4-decimal coords ≈ 100 m). `getToday` returns `DailyPrayerSchedule?` (null when offline + no cache). Constructed with `PrayerRepository(cache: await PrayerRepository.openBox())`.
* `SettingsRepository` — Hive-backed (`notifications_enabled`, `gps_distance_filter_m`, `language_code`)

### 5.3. Presentation Layer
* **Cubits:** `LocationCubit` (sealed `LocationState`: Initial/Manual/Gps/Denied), `SettingsCubit`
* **Cross-platform widgets:** `ArtisticCard` (single global card), `PlatformAwareScaffold/Button/NavShell` (iOS Cupertino ↔ Material 3 adaptive), `PermissionGate`, `PrayerTimeRow`, `QiblaCompass` (CustomPaint), `MonthGrid` (7-col reusable calendar grid with today + selection states)
* **Screens:** `DashboardScreen` (location header [tappable → location selector] + daily hadith + prayer list, responsive 1/2 column), `CalendarScreen` (month nav header + MonthGrid + selected day's prayer schedule), `QiblaCompassScreen` (live heading + sensor-unsupported fallback), `HadithListScreen` (browse all hadiths as preview cards), `HadithDetailScreen` (full text + prev/next navigation), `LocationSelectorScreen` (cascading dropdowns), `SettingsScreen` (Konum entry → location selector, notif toggle, GPS distance, language picker, about)
* **Navigation:** Bottom nav with 5 tabs (Bugün / Takvim / Kıble / Hadisler / Ayarlar) via `PlatformAwareNavShell`. Konum seçici no longer a tab — reachable via Dashboard location header tap **or** Settings → Konum entry. Implemented with `CupertinoTabScaffold` on iOS, Material 3 `NavigationBar` elsewhere.

### 5.4. App Entry
* `main.dart` — Hive init, repo/cubit bootstrap, `MultiRepositoryProvider` + `MultiBlocProvider` at root, `PlatformAwareNavShell` as home

### 5.4.1 Tests
* `test/data/datasources/prayer_repository_test.dart` — 7 cases covering fresh fetch, cache hit, TTL expiry refresh, past-month never-expire, stale-while-error, no-cache + API failure, and `getToday`. Uses `http`'s `MockClient` and a temp-dir Hive box; injects `now` and `ttl` via `PrayerRepository` constructor for deterministic time control.

> The legacy `test/widget_test.dart` is unedited `flutter create` boilerplate (refers to a non-existent `MyApp`); delete or rewrite before running `flutter test`.

### 5.5. Assets
* `assets/data/hadiths.json` — 2 sample entries (Riyad as-Salihin)
* `assets/data/locations.json` — 1 sample (TR → İstanbul → Üsküdar)

### 5.6. Development Setup (Phone Testing)

> Not yet installed on this machine. Install when ready to run on a physical device.

**Common (both platforms):**
1. Install Flutter SDK: `brew install --cask flutter` (recommended) **or** download stable channel from <https://docs.flutter.dev/get-started/install>
2. `cd /Users/veyselgunes/Desktop/Project/irfantakvim && flutter pub get`
3. `flutter doctor` — follow any remaining warnings

**Android path:**
4a. Install Android Studio (`brew install --cask android-studio`) OR command-line tools only (`brew install --cask android-commandlinetools` + `sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"`)
5a. Accept licenses: `flutter doctor --android-licenses`
6a. Phone: enable Developer Options → USB Debugging → connect via cable → trust prompt
7a. Verify: `adb devices` (device should appear)
8a. Run: `flutter run` (auto-detects device)
9a. Add `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>` and notification perms to `android/app/src/main/AndroidManifest.xml` after first `flutter create .` populates the folder.

**iOS path:**
4b. Install full Xcode from App Store (~15 GB), then `sudo xcode-select -s /Applications/Xcode.app`, accept license: `sudo xcodebuild -license accept`
5b. `brew install cocoapods` and run `pod setup`
6b. Phone: trust this Mac when prompted; in Xcode → Signing & Capabilities select a free personal team for the Runner target
7b. Add to `ios/Runner/Info.plist`:
   * `NSLocationWhenInUseUsageDescription` — "Namaz vakitleri için konumunuz kullanılır"
   * `UIBackgroundModes` → `location`, `fetch`
8b. Run: `flutter run` (auto-detects device)

### 5.7. Internationalization
* **Supported locales:** Turkish (`tr`, default), English (`en`), Arabic (`ar`)
* `flutter_localizations` enabled → date/time pickers, dialogs, RTL layout for Arabic auto-handled
* `AppStrings` (`lib/core/constants/app_strings.dart`) — lightweight map-based string lookup; no codegen. Currently covers Settings screen + bottom nav tab labels. Extend `_table` to translate more strings.
* `SettingsCubit.setLanguage(code)` persists choice in Hive; `MaterialApp` wrapped in `BlocBuilder<SettingsCubit>` so the whole tree rebuilds on change (no app restart needed).
* User-facing string in screens: `AppStrings.of(context).t('key')`

