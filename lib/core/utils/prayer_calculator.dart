import '../constants/prayer_constants.dart';

/// Pure math — no framework dependencies.
/// Handles calculation of missed (kaza) prayers following the Hanafi school.
class PrayerCalculator {
  PrayerCalculator._();

  /// Default puberty age used when none is supplied.
  static const int defaultPubertyAge = 13;

  /// The 6 daily vakit tracked (5 fard + Witr wajib).
  /// Keys are stable identifiers; display names live in [PrayerConstants].
  static const List<String> vakitKeys = PrayerConstants.prayerKeys;

  /// Rakat counts per vakit. Total = 20 rakats/day.
  static const Map<String, int> rakatsPerVakit = PrayerConstants.fardRakats;

  // ───────────────────────────────────────────────────────────────────────────
  // Primary calculation
  // ───────────────────────────────────────────────────────────────────────────

  /// Calculates the kaza prayer debt.
  ///
  /// [birthDate]        : User's date of birth.
  /// [pubertyAge]       : Age (years) at which prayer became fard. Defaults to 13.
  /// [prayerStartDate]  : Date the user began praying regularly.
  /// [estimatedOffDays] : Total excused days to subtract (illness, menstruation,
  ///                      travel, etc.). Defaults to 0.
  ///
  /// Returns a [KazaCalculationResult] holding total days, per-vakit breakdown,
  /// and total rakats.
  static KazaCalculationResult calculate({
    required DateTime birthDate,
    int? pubertyAge,
    required DateTime prayerStartDate,
    int estimatedOffDays = 0,
  }) {
    final age = pubertyAge ?? defaultPubertyAge;

    // The day the user reached puberty (birthday + pubertyAge years).
    final pubertyDate = DateTime(
      birthDate.year + age,
      birthDate.month,
      birthDate.day,
    );

    // Days between reaching puberty and starting regular prayer.
    final rawDays = prayerStartDate.difference(pubertyDate).inDays;

    // Subtract excused days; never go below zero.
    final totalDaysDebt =
        (rawDays - estimatedOffDays).clamp(0, rawDays < 0 ? 0 : rawDays);

    // Each vakit is missed once per debt-day.
    final breakdown = <String, int>{
      for (final key in vakitKeys) key: totalDaysDebt,
    };

    return KazaCalculationResult(
      totalDays: totalDaysDebt,
      pubertyDate: pubertyDate,
      breakdown: breakdown,
      totalRakats: totalDaysDebt * PrayerConstants.totalDailyRakats,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────────────────────────────────

  /// Converts a per-vakit count map into a per-vakit rakat map.
  static Map<String, int> toRakats(Map<String, int> counts) => {
        for (final entry in counts.entries)
          entry.key: entry.value * (rakatsPerVakit[entry.key] ?? 0),
      };

  /// Total number of kaza prayers across all vakit.
  static int totalCount(Map<String, int> counts) =>
      counts.values.fold(0, (a, b) => a + b);

  /// Total rakats across all vakit.
  static int totalRakats(Map<String, int> counts) =>
      toRakats(counts).values.fold(0, (a, b) => a + b);

  /// Estimates the completion date given a remaining-debt map and a uniform
  /// daily target per vakit. Returns null when the target is zero.
  static DateTime? estimateCompletionDate({
    required Map<String, int> remaining,
    required int dailyTargetPerVakit,
    DateTime? from,
  }) {
    if (dailyTargetPerVakit <= 0) return null;
    final start = from ?? DateTime.now();

    int maxDays = 0;
    for (final key in vakitKeys) {
      final count = remaining[key] ?? 0;
      final days = (count / dailyTargetPerVakit).ceil();
      if (days > maxDays) maxDays = days;
    }
    if (maxDays == 0) return null;
    return start.add(Duration(days: maxDays));
  }

  /// Daily target map for the three difficulty modes (1 / 2 / 4 per vakit).
  static Map<String, int> dailyTargetsFromMode(String mode) {
    final multiplier = switch (mode) {
      'easy' => 1,
      'medium' => 2,
      'hard' => 4,
      _ => 1,
    };
    return {for (final k in vakitKeys) k: multiplier};
  }
}

/// Structured output of a kaza debt calculation.
class KazaCalculationResult {
  /// Total number of full days of missed prayers.
  final int totalDays;

  /// The computed puberty date (birthday + pubertyAge).
  final DateTime pubertyDate;

  /// Per-vakit missed prayer counts (fajr, dhuhr, asr, maghrib, isha, witr).
  final Map<String, int> breakdown;

  /// Total rakats across all missed prayers (totalDays * 20).
  final int totalRakats;

  const KazaCalculationResult({
    required this.totalDays,
    required this.pubertyDate,
    required this.breakdown,
    required this.totalRakats,
  });

  /// Total number of individual kaza prayers (6 per day).
  int get totalPrayers =>
      breakdown.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toMap() => {
        'totalDays': totalDays,
        'pubertyDate': pubertyDate.toIso8601String(),
        'breakdown': breakdown,
        'totalRakats': totalRakats,
      };

  @override
  String toString() =>
      'KazaCalculationResult(totalDays: $totalDays, totalRakats: $totalRakats, breakdown: $breakdown)';
}
