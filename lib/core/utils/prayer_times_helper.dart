import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kaza_takip/core/constants/app_constants.dart';
import 'package:kaza_takip/core/di/injection_container.dart';

/// Bir günün 6 vakti — Diyanet uyumlu (İmsak/Güneş dahil).
class DailyPrayerTimes {
  final DateTime imsak;
  final DateTime gunes;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  /// Bir sonraki günün imsak vakti — Yatsı sonrası geri sayım için.
  final DateTime nextImsak;

  const DailyPrayerTimes({
    required this.imsak,
    required this.gunes,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.nextImsak,
  });

  /// İçinde bulunulan vakit (kaza UI'sındaki 6'lı anahtar setiyle birebir).
  /// Sabah vakti: imsak..gunes; Öğle: dhuhr..asr; İkindi: asr..maghrib;
  /// Akşam: maghrib..isha; Yatsı: isha..nextImsak.
  /// (gunes..dhuhr arası "kerahat" — bir sonraki vakte gerisayım yaparız.)
  String currentVakitKey(DateTime now) {
    if (now.isBefore(imsak)) return 'isha';
    if (now.isBefore(gunes)) return 'fajr';
    if (now.isBefore(dhuhr)) return 'fajr'; // kerahat — yine sabah vakti say
    if (now.isBefore(asr)) return 'dhuhr';
    if (now.isBefore(maghrib)) return 'asr';
    if (now.isBefore(isha)) return 'maghrib';
    return 'isha';
  }

  /// Mevcut vaktin bitiş zamanı.
  DateTime currentVakitEnd(DateTime now) {
    if (now.isBefore(imsak)) return imsak;
    if (now.isBefore(gunes)) return gunes;
    if (now.isBefore(dhuhr)) return dhuhr;
    if (now.isBefore(asr)) return asr;
    if (now.isBefore(maghrib)) return maghrib;
    if (now.isBefore(isha)) return isha;
    return nextImsak;
  }
}

/// Konuma göre 6 vakti hesaplar — adhan + Türkiye yöntemi.
class PrayerTimesHelper {
  PrayerTimesHelper._();

  static Coordinates _resolveCoordinates() {
    final prefs = sl<SharedPreferences>();
    final lat = prefs.getDouble(AppConstants.prefLatitude) ??
        AppConstants.defaultLatitude;
    final lng = prefs.getDouble(AppConstants.prefLongitude) ??
        AppConstants.defaultLongitude;
    return Coordinates(lat, lng);
  }

  static DailyPrayerTimes forDate(DateTime date) {
    final coords = _resolveCoordinates();
    final params = CalculationMethod.turkey.getParameters();

    final today = PrayerTimes(
      coords,
      DateComponents.from(date),
      params,
    );
    final tomorrow = PrayerTimes(
      coords,
      DateComponents.from(date.add(const Duration(days: 1))),
      params,
    );

    return DailyPrayerTimes(
      imsak: today.fajr,
      gunes: today.sunrise,
      dhuhr: today.dhuhr,
      asr: today.asr,
      maghrib: today.maghrib,
      isha: today.isha,
      nextImsak: tomorrow.fajr,
    );
  }

  /// Tek seferlik "bugün" hesaplaması.
  static DailyPrayerTimes today() => forDate(DateTime.now());
}
