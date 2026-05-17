/// A single religious day in the Türkiye Diyanet calendar.
///
/// [date] is the Gregorian observance date (date-only, no time component).
/// [type] is a coarse category used for display badges:
///   - `kandil` → Berat / Regaib / Mi'rac / Mevlid / Kadir gecesi
///   - `bayram` → Ramazan or Kurban bayramı günleri
///   - `ay`     → Ramazan başlangıcı, Hicri Yılbaşı
///   - `gun`    → Aşure ve benzeri münferit günler
///   - `gece`   → Kadir Gecesi gibi gece odaklı vurgular
class ReligiousDay {
  final DateTime date;
  final String name;
  final String type;
  final String hijri;

  const ReligiousDay({
    required this.date,
    required this.name,
    required this.type,
    required this.hijri,
  });

  factory ReligiousDay.fromJson(Map<String, dynamic> j) {
    final raw = j['date'] as String; // YYYY-MM-DD
    final parts = raw.split('-');
    return ReligiousDay(
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
      name: j['name'] as String,
      type: j['type'] as String,
      hijri: j['hijri'] as String,
    );
  }
}
