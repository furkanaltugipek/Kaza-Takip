import 'package:equatable/equatable.dart';

/// Completion status for a single day.
enum DailyStatus { completed, partial, none }

extension DailyStatusX on DailyStatus {
  /// Stable string used for storage/serialization.
  String get value => switch (this) {
        DailyStatus.completed => 'COMPLETED',
        DailyStatus.partial => 'PARTIAL',
        DailyStatus.none => 'NONE',
      };

  static DailyStatus fromValue(String raw) => switch (raw) {
        'COMPLETED' => DailyStatus.completed,
        'PARTIAL' => DailyStatus.partial,
        _ => DailyStatus.none,
      };
}

/// A record of how many kaza prayers were completed on a given day.
///
/// Pure Dart, immutable. Used to build the contribution calendar and to
/// drive streak logic.
class DailyLog extends Equatable {
  /// The calendar day this log refers to (time component ignored).
  final DateTime date;

  /// One of: 'COMPLETED', 'PARTIAL', 'NONE'.
  final String status;

  /// Prayers completed on this day, keyed by vakit.
  final Map<String, int> completedToday;

  const DailyLog({
    required this.date,
    required this.status,
    required this.completedToday,
  });

  /// Creates a log with a status derived from completed vs. target counts.
  factory DailyLog.fromCounts({
    required DateTime date,
    required Map<String, int> completedToday,
    required int targetCount,
  }) {
    final total = completedToday.values.fold(0, (a, b) => a + b);
    final DailyStatus s;
    if (total == 0) {
      s = DailyStatus.none;
    } else if (total >= targetCount && targetCount > 0) {
      s = DailyStatus.completed;
    } else {
      s = DailyStatus.partial;
    }
    return DailyLog(
      date: DateTime(date.year, date.month, date.day),
      status: s.value,
      completedToday: completedToday,
    );
  }

  /// Total prayers completed on this day across all vakit.
  int get totalCompleted =>
      completedToday.values.fold(0, (a, b) => a + b);

  /// Typed status accessor.
  DailyStatus get statusEnum => DailyStatusX.fromValue(status);

  bool get isCompleted => statusEnum == DailyStatus.completed;

  DailyLog copyWith({
    DateTime? date,
    String? status,
    Map<String, int>? completedToday,
  }) {
    return DailyLog(
      date: date ?? this.date,
      status: status ?? this.status,
      completedToday: completedToday ?? this.completedToday,
    );
  }

  @override
  List<Object?> get props => [date, status, completedToday];
}
