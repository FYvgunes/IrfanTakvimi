import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/hadith_model.dart';

/// Fetches verified hadith collections from the fawazahmed0/hadith-api
/// CDN (Unlicense / public domain). Default edition is Sahih al-Bukhari
/// in Turkish translation — the gold-standard sahih source.
class HadithApiClient {
  static const _cdnBase = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';
  static const defaultEdition = 'tur-bukhari';
  static const defaultSourceLabel = 'Sahih al-Bukhari';

  final http.Client _http;
  final Duration _timeout;

  HadithApiClient({http.Client? httpClient, Duration? timeout})
      : _http = httpClient ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 60);

  Future<List<HadithModel>> fetchEdition({
    String edition = defaultEdition,
    String sourceLabel = defaultSourceLabel,
  }) async {
    final uri = Uri.parse('$_cdnBase/editions/$edition.min.json');
    final res = await _http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Hadith CDN ${res.statusCode} for $uri');
    }
    final body = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final raw = body['hadiths'] as List<dynamic>;
    return raw
        .map((h) {
          final m = h as Map<String, dynamic>;
          return HadithModel(
            id: (m['hadithnumber'] as num).toInt(),
            text: _cleanText(m['text'] as String),
            source: sourceLabel,
            hadithNo: (m['hadithnumber'] as num).toInt(),
          );
        })
        .toList(growable: false);
  }

  // Some texts include trailing cross-reference notes like "Tekrar: 54, 2529 …"
  // — keep only the hadith body so the daily quote stays readable. Heuristic:
  // cut at the first sentence-marker followed by "Tekrar:" or "Diğer Tahric".
  String _cleanText(String raw) {
    var t = raw.trim();
    for (final marker in const ['Tekrar:', 'Diğer Tahric', 'Diğer tahric']) {
      final idx = t.indexOf(marker);
      if (idx > 0) {
        t = t.substring(0, idx).trim();
        // strip trailing punctuation like " ." or ","
        while (t.endsWith(',') || t.endsWith('.')) {
          t = t.substring(0, t.length - 1).trim();
        }
        t = '$t.';
      }
    }
    return t;
  }

  void dispose() => _http.close();
}
