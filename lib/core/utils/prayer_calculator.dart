import '../constants/prayer_constants.dart';

/// Pure math — no framework dependencies.
/// All calculations follow the Hanafi school of jurisprudence.
class PrayerCalculator {
  PrayerCalculator._();

  /// Calculates total kaza debt for each prayer type.
  ///
  /// [birthDate]        : User's date of birth.
  /// [pubertyDate]      : Date when the user reached puberty (baligh).
  /// [regularStartDate] : Date when the user started praying regularly.
  /// [isFemale]         : Whether to subtract menstrual exemptions.
  ///
  /// Returns a map of prayerKey → missed count.
  static Map<String, int> calculateKazaDebt({
    required DateTime birthDate,
    required DateTime pubertyDate,
    required DateTime regularStartDate,
    required bool isFemale,
  }) {
    // The debt window: from puberty until user started praying regularly.
    // If regularStartDate <= pubertyDate, there is no debt.
    if (!regularStartDate.isAfter(pubertyDate)) {
      return {for (final k in PrayerConstants.prayerKeys) k: 0};
    }

    final totalDays = regularStartDate.difference(pubertyDate).inDays;
    final totalMonths = totalDays / 30.4375; // average Gregorian month

    int basePrayersPerKey = totalDays; // each key missed once per day

    // Female exemption: menstrual + nifas (postnatal bleeding).
    // Prayers are NOT made up for menstrual/nifas periods.
    // Fasting IS made up — handled in fasting module.
    int exemptDays = 0;
    if (isFemale) {
      // Exempt ~7 days/month for hayd (menstruation).
      exemptDays = (totalMonths * PrayerConstants.avgMenstrualDaysPerMonth).round();
    }

    final effectiveDays = (totalDays - exemptDays).clamp(0, totalDays);

    final Map<String, int> result = {};
    for (final key in PrayerConstants.prayerKeys) {
      result[key] = effectiveDays;
    }
    return result;
  }

  /// Converts per-prayer kaza counts to total rakats.
  static Map<String, int> toRakats(Map<String, int> kazaCounts) {
    final Map<String, int> rakats = {};
    for (final entry in kazaCounts.entries) {
      rakats[entry.key] =
          entry.value * (PrayerConstants.fardRakats[entry.key] ?? 0);
    }
    return rakats;
  }

  /// Total number of kaza prayers across all types.
  static int totalKazaCount(Map<String, int> kazaCounts) =>
      kazaCounts.values.fold(0, (a, b) => a + b);

  /// Total kaza rakats across all prayer types.
  static int totalRakatCount(Map<String, int> kazaCounts) =>
      toRakats(kazaCounts).values.fold(0, (a, b) => a + b);

  /// Estimates the finish date given daily targets per prayer.
  ///
  /// [kazaCounts]    : current remaining kaza per prayer key.
  /// [dailyTargets]  : how many extra kaza prayers per type per day.
  ///
  /// Returns the estimated completion [DateTime], or null if targets are zero.
  static DateTime? estimateCompletionDate({
    required Map<String, int> kazaCounts,
    required Map<String, int> dailyTargets,
    DateTime? startDate,
  }) {
    final start = startDate ?? DateTime.now();

    // Find the prayer that takes the longest to clear.
    int maxDays = 0;
    for (final key in PrayerConstants.prayerKeys) {
      final remaining = kazaCounts[key] ?? 0;
      final daily = dailyTargets[key] ?? 0;
      if (daily <= 0) continue;
      final days = (remaining / daily).ceil();
      if (days > maxDays) maxDays = days;
    }

    if (maxDays == 0) return null;
    return start.add(Duration(days: maxDays));
  }

  /// Builds the daily kaza count from a mode string.
  static Map<String, int> dailyTargetsFromMode(String mode) {
    final multiplier = _modeMultiplier(mode);
    return {for (final k in PrayerConstants.prayerKeys) k: multiplier};
  }

  static int _modeMultiplier(String mode) {
    switch (mode) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 4;
      default:
        return 1;
    }
  }

  /// Returns how many days have passed since puberty (for display).
  static int daysSincePuberty(DateTime pubertyDate) =>
      DateTime.now().difference(pubertyDate).inDays.clamp(0, 999999);
}
