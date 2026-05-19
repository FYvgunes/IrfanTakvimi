# İrfan Takvimi — Todo

> Yaşayan görev listesi. CLAUDE.md §5 "Implemented Features" canlı kaynak; bu dosya ise neyi yaptık / sırada ne var bakışı.

---

## ✅ Yapılanlar

### Altyapı & Mimari
- [x] Clean Architecture klasör yapısı (`core/` · `data/` · `presentation/`)
- [x] Hive init + repository / cubit bootstrap (`main.dart`)
- [x] `MultiRepositoryProvider` + `MultiBlocProvider` kök ağacı
- [x] Tema sistemi: "Parşömen" paleti (EB Garamond + Inter, Google Fonts)
- [x] **Dark mode** — `buildAppTheme(brightness)` + `AppPalette` ThemeExtension + `context.palette` getter
- [x] Ayarlar'da Tema toggle (Sistem / Açık / Koyu) — Hive'a kayıtlı
- [x] i18n iskeleti — `tr` / `en` / `ar`, `AppStrings` map-based, RTL otomatik
- [x] Responsive helper (`Breakpoints`, `Responsive.value()`)

### Konum
- [x] `LocationModel` sealed (Manual | GPS)
- [x] `LocationCubit` sealed state (Initial / Manual / Gps / Denied)
- [x] `LocationService` (geolocator, izin akışı, distance-filtered stream)
- [x] `LocationRepository` — 81 il + 973 ilçe (Türkiye API, MIT)
- [x] `nearestLocation()` haversine → GPS koordinatından en yakın il adı
- [x] `LocationSelectorScreen` — `PickerField` + arama destekli full-page picker
- [x] Ayarlar → GPS kartı (canlı durum + izin tekrar isteme)

### Namaz Vakitleri
- [x] `AladhanClient` — `api.aladhan.com/v1/calendar`, `method=13` (Diyanet), `school=1` (Hanafi)
- [x] `PrayerRepository` — Hive cache-first, 30 gün TTL, geçmiş aylar kalıcı, stale-while-error
- [x] Dashboard hero kart: sonraki vakit + canlı geri sayım (sn-sn)
- [x] Bugünün 5 vakti aktif/sonraki vurgulu (`PrayerTimeRow`)
- [x] Calendar'da seçili günün vakitleri
- [x] **7 test case** (`prayer_repository_test.dart`) — fresh fetch, cache hit, TTL, geçmiş ay, stale, no-cache+fail, getToday

### Kıble
- [x] `qibla_calculator.dart` — atan2 bearing, Kâbe sabitleri
- [x] `compass_service.dart` — magnetometer + accelerometer stream
- [x] `QiblaCompass` CustomPaint + sensör desteklenmiyor fallback'i

### İçerik
- [x] `HadithApiClient` — Sahih al-Bukhari Türkçe (fawazahmed0, Unlicense)
- [x] `HadithRepository` — ilk açılışta ~7,589 hadis fetch + Hive'a kalıcı cache
- [x] Bundled offline fallback (`assets/data/hadiths.json`, 2 örnek)
- [x] `HadithListScreen` + `HadithDetailScreen` (önceki/sonraki nav)
- [x] Günün hadisi (deterministic by Unix day) — Dashboard
- [x] `EsmaRepository` — 99 Esmâ-ül Hüsnâ (Diyanet sırası, JSON)
- [x] Dashboard "Günün İsmi" kartı (Amiri Arabic + translit + meaning)
- [x] `ReligiousDayRepository` — Kandiller/Bayramlar (2026 + 2027 başı)
- [x] Calendar'da dini gün marker'ları + seçili gün banner
- [x] Dashboard "Bugün dini gün" rozeti

### Bildirimler
- [x] `NotificationService` arayüzü (5 günlük yerel bildirim + hadis payload)

### UI Bileşenleri
- [x] `ArtisticCard` (ivory / heritage varyantları)
- [x] `PlatformAwareButton` (primary / secondary / ghost — Cupertino/Material)
- [x] `PlatformAwareScaffold` + `NavShell` (5 sekme, "Bugün" = AppLogo)
- [x] `AppLogo` — saf vektör (iki copper halka + hilâl + tepe noktası), Islamic guardrail uyumlu
- [x] `MonthGrid` 7-kolon takvim, marked days üç-katmanlı vurgu
- [x] `PrayerTimeRow` (aktif / sonraki / varsayılan stilleri)
- [x] `Picker` + `showPicker<T>` — Türkçe-aware arama (ç→c, ı/İ→i…)
- [x] `_MonthYearPickerSheet` — hızlı ay/yıl atlama

### Web Deploy
- [x] Netlify config (`netlify.toml`)
- [x] PWA ikonları (192/512, maskable variants) — `tools/render_logo.py` ile üretiliyor
- [x] iOS Safari data detectors fix
- [x] `google_fonts` dart2js build sorunları (6.3.3 pin)

---

## ✅ Tamamlandı: Dark Mode Migrasyonu

Tüm dosyalar artık `context.palette` üzerinden dark-aware:

- [x] `lib/presentation/widgets/platform_aware_button.dart`
- [x] `lib/presentation/widgets/picker.dart`
- [x] `lib/presentation/widgets/qibla_compass.dart` (palet `_CompassPainter`'a geçiriliyor)
- [x] `lib/presentation/screens/hadith_list_screen.dart`
- [x] `lib/presentation/screens/hadith_detail_screen.dart`
- [x] `lib/presentation/screens/qibla_compass_screen.dart`
- [x] `lib/presentation/screens/location_selector_screen.dart`

`lib/` içinde artık `AppColors.*` referansı kalmadı — palet tamamen `context.palette` ile çözülüyor.

---

## 🔜 Sırada (Öncelik Sırasıyla)

### Yakın (1–2 oturum)
- [x] **Dark mode migrasyonunu bitir** (7 dosya — tamamlandı)
- [ ] `test/widget_test.dart` — `flutter create` boilerplate'i sil veya gerçek smoke test'le değiştir (şu an `flutter test` patlıyor)
- [ ] Bildirim akışını gerçek cihazda test et (yerel bildirim + hadis payload)
- [ ] iOS `Info.plist` izinleri (`NSLocationWhenInUseUsageDescription`, `UIBackgroundModes`) — telefon testi öncesi
- [ ] Android `AndroidManifest.xml` izinleri (FINE_LOCATION, notifications) — telefon testi öncesi

### Orta Vade
- [ ] **Annual data refresh workflow** — 2027 dini günleri (`assets/data/religious_days.json`) Diyanet'in yıllık takviminden doğrula
- [ ] i18n genişlet: `AppStrings._table` şu an sadece Ayarlar + nav tabs kapsıyor; Dashboard / Calendar / Hadith / Qibla ekranlarını da çevir
- [ ] Hadith koleksiyon seçici (Bukhari / Müslim / Tirmizi / Nevevî) — `HadithApiClient.fetchEdition` zaten parametrik, UI eksik
- [ ] Calendar'da Hicri tarih gösterimi (şu an sadece dini gün banner'ında var)
- [ ] District seviyesi koordinat hassasiyeti — şu an district'ler il merkezi koordinatını miras alıyor (±1–3 dk varyans)

### Uzak Vade / Fikir Aşaması
- [ ] Geniş ekran (tablet/desktop) layout iyileştirmeleri — `Responsive.value()` daha derin entegrasyon
- [ ] Bildirim ses seçimi (ezan klipleri — telif sorunu var, dikkat)
- [ ] Aylık namaz vakti PDF/share export
- [ ] Widget desteği (iOS WidgetKit / Android App Widget — sonraki vakit)
- [ ] Apple Watch / Wear OS — sadece sonraki vakit + Kıble

---

## 🛑 Engelleyiciler / Açık Sorular

- [ ] Geliştirme ortamı: Flutter SDK + Android Studio/Xcode bu makineye henüz kurulu değil (CLAUDE.md §5.6). Telefon testi yapılana kadar tüm cihaz-spesifik akışlar (bildirim, GPS izin diyaloğu, magnetometer doğruluğu) doğrulanmadı.
- [ ] Diyanet'in 2027 takvimi yayınlanır yayınlanmaz `religious_days.json` güncellenmeli (Hijri ay başları ±1 gün kayabiliyor).

---

> Bu dosyayı oturum sonlarında güncelle; CLAUDE.md §5'i de paralel tut.
