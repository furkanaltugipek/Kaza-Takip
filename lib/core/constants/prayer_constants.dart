class PrayerConstants {
  PrayerConstants._();

  // The 5 daily fard prayers + Witr (wajib, treated like fard for kaza)
  static const List<String> prayerNames = [
    'Sabah',
    'Öğle',
    'İkindi',
    'Akşam',
    'Yatsı',
    'Vitir',
  ];

  static const List<String> prayerKeys = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
    'witr',
  ];

  // Rakat counts for each prayer (fard only for kaza calculation)
  static const Map<String, int> fardRakats = {
    'fajr': 2,
    'dhuhr': 4,
    'asr': 4,
    'maghrib': 3,
    'isha': 4,
    'witr': 3,
  };

  static const int totalDailyRakats = 20; // 2+4+4+3+4+3

  // Default puberty age assumptions (Hanafi school)
  static const int defaultMalePubertyAge = 12;
  static const int defaultFemalePubertyAge = 9;

  // Average menstrual days per month (used for female calculation)
  static const double avgMenstrualDaysPerMonth = 7.0;
  static const double avgMenstrualPrayersSkippedPerMonth = 35.0; // 7 days * 5 prayers

  // Ramadan: avg fasting days per year
  static const double avgRamadanDays = 29.5;
}
