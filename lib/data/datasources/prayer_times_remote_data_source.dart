import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:kaza_takip/data/models/prayer_time_model.dart';

/// Aladhan Calendar API — Diyanet (method=13) ile aylık vakit dizisi.
class PrayerTimesRemoteDataSource {
  final http.Client _client;
  static const String _base = 'https://api.aladhan.com/v1/calendarByCity';

  /// Türkiye Diyanet İşleri Başkanlığı yöntem kodu.
  static const int diyanetMethod = 13;

  PrayerTimesRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  /// Türkçe şehir adlarını Aladhan'ın anladığı ASCII karşılığına çevirir.
  /// API "İstanbul" yerine "Istanbul", "İzmir" yerine "Izmir" bekliyor.
  static String asciiCity(String city) {
    const map = {
      'ı': 'i', 'İ': 'I',
      'ş': 's', 'Ş': 'S',
      'ğ': 'g', 'Ğ': 'G',
      'ü': 'u', 'Ü': 'U',
      'ö': 'o', 'Ö': 'O',
      'ç': 'c', 'Ç': 'C',
    };
    final buf = StringBuffer();
    for (final r in city.runes) {
      final ch = String.fromCharCode(r);
      buf.write(map[ch] ?? ch);
    }
    return buf.toString().trim();
  }

  /// Verilen şehir için [year] yılının [month] ayına ait 28–31 günlük diziyi getirir.
  ///
  /// Hata durumunda [PrayerTimesNetworkException] fırlatır — çağıran taraf
  /// önbelleğe ya da kullanıcıya bağlantı uyarısına düşer.
  Future<List<PrayerTimeModel>> fetchMonth({
    required String city,
    required int year,
    required int month,
    String country = 'Turkey',
  }) async {
    final asciiName = asciiCity(city);
    // Aladhan v1: path'te yıl/ay, query'de şehir+ülke+method.
    final uri = Uri.parse('$_base/$year/$month').replace(queryParameters: {
      'city': asciiName,
      'country': country,
      'method': diyanetMethod.toString(),
    });

    developer.log('Aladhan GET → $uri', name: 'PrayerTimesRemote');

    final http.Response res;
    try {
      res = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
    } catch (e) {
      developer.log('Ağ hatası: $e', name: 'PrayerTimesRemote', error: e);
      throw PrayerTimesNetworkException('Ağ hatası: $e');
    }

    if (res.statusCode != 200) {
      developer.log(
        'HTTP ${res.statusCode} — body=${res.body}',
        name: 'PrayerTimesRemote',
      );
      throw PrayerTimesNetworkException(
        'Aladhan ${res.statusCode}: ${res.reasonPhrase ?? ''}',
      );
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final code = body['code'];
    if (code is int && code != 200) {
      throw PrayerTimesNetworkException(
        'Aladhan code=$code: ${body['status'] ?? ''}',
      );
    }

    final data = body['data'];
    if (data is! List || data.isEmpty) {
      throw PrayerTimesNetworkException(
        'Aladhan boş veri döndü. Şehir adını kontrol edin: "$asciiName".',
      );
    }

    return data
        .whereType<Map>()
        .map((d) => PrayerTimeModel.fromAladhan(d.cast<String, dynamic>()))
        .toList();
  }

  void close() => _client.close();
}

class PrayerTimesNetworkException implements Exception {
  final String message;
  const PrayerTimesNetworkException(this.message);
  @override
  String toString() => 'PrayerTimesNetworkException: $message';
}
