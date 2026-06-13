import 'package:equatable/equatable.dart';
import 'package:kaza_takip/core/constants/prayer_constants.dart';

/// Aggregate progress metrics for a user's kaza journey.
///
/// Pure Dart, immutable. [totalDebts] and [completedDebts] are keyed by
/// vakit (fajr, dhuhr, asr, maghrib, isha, witr).
class KazaMetrics extends Equatable {
  /// Original total debt per vakit (the calculated starting point).
  final Map<String, int> totalDebts;

  /// Prayers completed so far per vakit.
  final Map<String, int> completedDebts;

  /// Current consecutive-day streak.
  final int currentStreak;

  /// Best streak ever achieved.
  final int longestStreak;

  const KazaMetrics({
    required this.totalDebts,
    required this.completedDebts,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  /// An empty metrics object with all vakit set to zero.
  factory KazaMetrics.empty() => KazaMetrics(
        totalDebts: {for (final k in PrayerConstants.prayerKeys) k: 0},
        completedDebts: {for (final k in PrayerConstants.prayerKeys) k: 0},
      );

  // ── Derived getters ─────────────────────────────────────────────────────────

  /// Sum of all original debts.
  int get totalDebtCount =>
      totalDebts.values.fold(0, (a, b) => a + b);

  /// Sum of all completed prayers.
  int get totalCompletedCount =>
      completedDebts.values.fold(0, (a, b) => a + b);

  /// Remaining prayers across all vakit (never negative).
  int get totalRemaining =>
      (totalDebtCount - totalCompletedCount).clamp(0, 1 << 31);

  /// Remaining count for a single vakit.
  int remainingFor(String vakitKey) {
    final total = totalDebts[vakitKey] ?? 0;
    final done = completedDebts[vakitKey] ?? 0;
    return (total - done).clamp(0, 1 << 31);
  }

  /// Completion ratio in the range 0.0–1.0.
  double get completionPercentage {
    if (totalDebtCount == 0) return 0;
    return (totalCompletedCount / totalDebtCount).clamp(0.0, 1.0);
  }

  /// Total rakats still owed across all vakit.
  int get totalRakatsRemaining {
    var sum = 0;
    for (final key in PrayerConstants.prayerKeys) {
      sum += remainingFor(key) * (PrayerConstants.fardRakats[key] ?? 0);
    }
    return sum;
  }

  /// True when every vakit's debt has been cleared.
  bool get isFullyCompleted => totalRemaining == 0 && totalDebtCount > 0;

  KazaMetrics copyWith({
    Map<String, int>? totalDebts,
    Map<String, int>? completedDebts,
    int? currentStreak,
    int? longestStreak,
  }) {
    return KazaMetrics(
      totalDebts: totalDebts ?? this.totalDebts,
      completedDebts: completedDebts ?? this.completedDebts,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  @override
  List<Object?> get props =>
      [totalDebts, completedDebts, currentStreak, longestStreak];
}
