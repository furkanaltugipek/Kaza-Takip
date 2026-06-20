import 'dart:convert';

import 'package:kaza_takip/data/datasources/local/hive_datasource.dart';
import 'package:kaza_takip/data/models/prayer_time_model.dart';

/// Aladhan aylık dizisini Hive'da saklar/okur.
///
/// Anahtar formatı: `<cityKey>_<yyyy-MM>`. `cityKey` = küçük harfli, boşlukları
/// "_" ile değiştirilmiş şehir adı — Türkçe karakterler korunur.
class PrayerTimesLocalDataSource {
  final HiveLocalDataSource _hive;

  PrayerTimesLocalDataSource(this._hive);

  static String cityKey(String city) =>
      city.trim().toLowerCase().replaceAll(' ', '_');

  static String monthKey(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  static String _composite(String city, int year, int month) =>
      '${cityKey(city)}_${monthKey(year, month)}';

  /// Belirli ayı önbellekten getirir; yoksa null döner.
  List<PrayerTimeModel>? getMonth({
    required String city,
    required int year,
    required int month,
  }) {
    final raw = _hive.getPrayerTimesRaw(_composite(city, year, month));
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((m) => PrayerTimeModel.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Aylık dizilimi JSON olarak yazar.
  Future<void> putMonth({
    required String city,
    required int year,
    required int month,
    required List<PrayerTimeModel> data,
  }) {
    final encoded = jsonEncode(data.map((m) => m.toJson()).toList());
    return _hive.putPrayerTimesRaw(_composite(city, year, month), encoded);
  }

  /// Şehir değişiminde — eski şehrin tüm aylık önbelleklerini temizler.
  Future<void> clearCity(String city) =>
      _hive.clearPrayerTimesForCity(cityKey(city));
}
