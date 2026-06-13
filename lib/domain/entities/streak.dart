import 'package:equatable/equatable.dart';

class Streak extends Equatable {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final int totalCompletedDays;

  const Streak({
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.totalCompletedDays = 0,
  });

  bool get isAliveToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      lastCompletedDate!.year,
      lastCompletedDate!.month,
      lastCompletedDate!.day,
    );
    return last.isAtSameMomentAs(today) ||
        last.isAtSameMomentAs(today.subtract(const Duration(days: 1)));
  }

  Streak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    int? totalCompletedDays,
  }) {
    return Streak(
      userId: userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      totalCompletedDays: totalCompletedDays ?? this.totalCompletedDays,
    );
  }

  @override
  List<Object?> get props =>
      [userId, currentStreak, longestStreak, lastCompletedDate];
}
