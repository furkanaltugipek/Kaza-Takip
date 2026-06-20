import 'package:kaza_takip/core/utils/prayer_times_helper.dart';

/// Aladhan API'sinden gelen veya Hive'da saklanan tek bir günün 6 vakti.
///
/// Tüm vakitler 24 saat formatlı "HH:mm" stringidir. Zamanlama gösterimi için
/// dize biçiminde tutmak, dosya boyutunu küçültür ve dil bağımsızdır.
class PrayerTimeModel {
  final DateTime date; // sadece yıl/ay/gün — saat yok
  final String imsak;
  final String gunes;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  const PrayerTimeModel({
    required this.date,
    required this.imsak,
    required this.gunes,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  // ── Aladhan parse ──────────────────────────────────────────────────────────
  //
  // Aladhan günlük öğesi şu yapıdadır:
  // {
  //   "timings": { "Fajr": "05:01 (+03)", "Sunrise": "06:30", ... },
  //   "date":    { "gregorian": { "date": "01-06-2026", ... }, ... }
  // }
  factory PrayerTimeModel.fromAladhan(Map<String, dynamic> day) {
    final timings = (day['timings'] as Map).cast<String, dynamic>();
    final dateBlock = (day['date'] as Map).cast<String, dynamic>();
    final gregorian = (dateBlock['gregorian'] as Map).cast<String, dynamic>();
    final dateStr = gregorian['date'] as String; // "DD-MM-YYYY"

    final parts = dateStr.split('-');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    String hhmm(String raw) {
      // "05:01 (+03)" → "05:01"
      final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw.trim());
      if (match == null) return raw.trim();
      final h = match.group(1)!.padLeft(2, '0');
      final m = match.group(2)!;
      return '$h:$m';
    }

    return PrayerTimeModel(
      date: date,
      imsak: hhmm(timings['Imsak'] as String),
      gunes: hhmm(timings['Sunrise'] as String),
      dhuhr: hhmm(timings['Dhuhr'] as String),
      asr: hhmm(timings['Asr'] as String),
      maghrib: hhmm(timings['Maghrib'] as String),
      isha: hhmm(timings['Isha'] as String),
    );
  }

  // ── JSON ↔ Hive ────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'imsak': imsak,
        'gunes': gunes,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) => PrayerTimeModel(
        date: DateTime.parse(json['date'] as String),
        imsak: json['imsak'] as String,
        gunes: json['gunes'] as String,
        dhuhr: json['dhuhr'] as String,
        asr: json['asr'] as String,
        maghrib: json['maghrib'] as String,
        isha: json['isha'] as String,
      );

  // ── Geri sayım / vakit hesabı için yardımcı ────────────────────────────────

  /// HH:mm zamanlarını, bu günün tarihiyle birleştirerek `DateTime`'a çevirir.
  /// `nextImsak` parametresi yarınki imsak vakti olmalıdır.
  DailyPrayerTimes toDailyPrayerTimes({required PrayerTimeModel nextDay}) {
    DateTime t(String hhmm) {
      final p = hhmm.split(':');
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(p[0]),
        int.parse(p[1]),
      );
    }

    final next = nextDay;
    DateTime tn(String hhmm) {
      final p = hhmm.split(':');
      return DateTime(
        next.date.year,
        next.date.month,
        next.date.day,
        int.parse(p[0]),
        int.parse(p[1]),
      );
    }

    return DailyPrayerTimes(
      imsak: t(imsak),
      gunes: t(gunes),
      dhuhr: t(dhuhr),
      asr: t(asr),
      maghrib: t(maghrib),
      isha: t(isha),
      nextImsak: tn(nextDay.imsak),
    );
  }
}
