# İrfan Takvimi

Manevi ve sanatsal bir takvim uygulaması: doğru namaz vakitleri, konum tabanlı kıble bulucu ve doğrulanmış kaynaklardan günlük hadis bildirimleri.

Cross-platform (iOS, Android, web) Flutter uygulaması. Minimalist, sanatsal arayüz — zümrüt yeşili, parşömen krem ve derin indigo paleti.

## Özellikler

- **Namaz vakitleri (Diyanet metodu).** Aladhan API üzerinden Diyanet İşleri Başkanlığı parametreleriyle (Fajr 18°, Isha 17°, Hanefi Asr) aylık hesap. Hive ile cache: 30 günlük TTL, geçmiş aylar hiç expire olmaz, offline durumda stale veri sunulur.
- **Konum: manuel veya GPS.** Ülke → Şehir → İlçe seçimi veya GPS akışı. GPS izni reddedilirse seçili konuma graceful fallback. Seyahatte mesafe filtresine (5 km) göre otomatik yeniden hesap.
- **Kıble pusulası.** Manyetometre + ivmeölçer akışıyla Kabe (`21.4225° N, 39.8262° E`) yönüne canlı bearing. CustomPainter ile özel çizilmiş kompas.
- **Doğrulanmış hadis bildirimleri.** **Sıfır tolerans** uydurma/zayıf hadise. Yalnızca *Riyad as-Salihin* öncelikli olmak üzere sahih kaynaklardan asset JSON. 5 vakitte günlük bildirim, hadis payload olarak enjekte edilir.
- **i18n.** Türkçe (default), İngilizce, Arapça. Arapça için otomatik RTL.
- **Cross-platform UI.** iOS'ta Cupertino, diğer platformlarda Material 3 — platform-aware shell ile şeffaf.

## Mimari

Clean architecture: `core/` (servisler + util'ler), `data/` (model + repository), `presentation/` (cubit + screen + widget).

State: Cubit/Bloc. Cache: Hive. HTTP: `package:http`. Konum: `geolocator`. Pusula: `flutter_compass`. Bildirim: `flutter_local_notifications`.

Derin teknik spec ve dosya-dosya dökümler için → [`CLAUDE.md`](./CLAUDE.md).

## Kurulum

```bash
flutter pub get
flutter run        # bağlı cihazı otomatik bulur
flutter test       # birim testler
```

Flutter SDK ≥ 3.19, Dart ≥ 3.3. Mobil cihaz kurulum adımları (Android USB debug, iOS Xcode imzalama, Info.plist izinleri) `CLAUDE.md` §5.6'da.

## Test

```bash
flutter test
```

Mevcut kapsama: `PrayerRepository` için 8 case (fresh fetch, cache hit, TTL expiry, past-month never-expire, stale-while-error, no-cache+error, `getToday` happy & error). `http`'in `MockClient`'ı + temp-dir Hive ile deterministic.

## İçerik Guardrail

Hadis verisi sadece doğrulanmış kaynaklardan eklenir. Yeni hadis önerirken:

1. Kaynağı belirt (öncelik: Riyad as-Salihin, sonra Buhârî/Müslim/Sünen).
2. Hadis numarasını yaz.
3. `assets/data/hadiths.json` şemasına uy.

Uydurma (*mawdu'*) veya zayıf hadis kabul edilmez.

## Veri Kaynakları

- Namaz vakitleri: [Aladhan API](https://aladhan.com/prayer-times-api) (`method=13`, Diyanet İşleri Başkanlığı)
- Hadis metinleri: Riyad as-Salihin (İmam Nevevî derlemesi)

## Lisans

Henüz belirlenmedi.
