class HadithModel {
  final int id;
  final String text;
  final String source;
  final int hadithNo;

  const HadithModel({
    required this.id,
    required this.text,
    required this.source,
    required this.hadithNo,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) => HadithModel(
        id: json['id'] as int,
        text: json['text'] as String,
        source: json['source'] as String,
        hadithNo: json['hadith_no'] as int,
      );
}
