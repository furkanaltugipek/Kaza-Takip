import 'dart:convert';

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
    final uri = Uri.parse(_base).replace(queryParameters: {
      'city': city,
      'country': country,
      'method': diyanetMethod.toString(),
      'month': month.toString(),
      'year': year.toString(),
    });

    final http.Response res;
    try {
      res = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
    } catch (e) {
      throw PrayerTimesNetworkException('Ağ hatası: $e');
    }

    if (res.statusCode != 200) {
      throw PrayerTimesNetworkException(
        'Aladhan ${res.statusCode}: ${res.reasonPhrase ?? ''}',
      );
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is! List) {
      throw PrayerTimesNetworkException('Beklenen "data" listesi bulunamadı.');
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
