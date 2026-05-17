/// One of the 99 Names of Allah (Esmâ-ül Hüsnâ).
class EsmaModel {
  /// 1-99 in canonical Diyanet/Turkish ordering.
  final int id;

  /// Arabic name with traditional voweling.
  final String arabic;

  /// Turkish transliteration with diacritics (e.g., "Er-Rahmân").
  final String translit;

  /// Short Turkish gloss (1 sentence).
  final String meaning;

  const EsmaModel({
    required this.id,
    required this.arabic,
    required this.translit,
    required this.meaning,
  });

  factory EsmaModel.fromJson(Map<String, dynamic> j) => EsmaModel(
        id: j['id'] as int,
        arabic: j['arabic'] as String,
        translit: j['translit'] as String,
        meaning: j['meaning'] as String,
      );
}
