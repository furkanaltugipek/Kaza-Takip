import 'package:equatable/equatable.dart';

/// The user's chosen completion plan / pace.
///
/// Pure Dart, immutable. Drives the simulator and the daily target shown on
/// the dashboard.
class UserPlan extends Equatable {
  /// Desired number of months to clear the full debt (informational target).
  final int targetMonths;

  /// How many kaza prayers per vakit the user commits to each day.
  final int dailyTargetPerVakit;

  /// Projected date the debt will be fully cleared at the current pace.
  final DateTime estimatedFinishDate;

  const UserPlan({
    required this.targetMonths,
    required this.dailyTargetPerVakit,
    required this.estimatedFinishDate,
  });

  /// A neutral default plan (1 prayer/vakit/day, finishing "now" as a stub).
  factory UserPlan.initial() => UserPlan(
        targetMonths: 12,
        dailyTargetPerVakit: 1,
        estimatedFinishDate: DateTime.now(),
      );

  /// Days remaining until the estimated finish date (never negative).
  int get daysRemaining {
    final diff = estimatedFinishDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  UserPlan copyWith({
    int? targetMonths,
    int? dailyTargetPerVakit,
    DateTime? estimatedFinishDate,
  }) {
    return UserPlan(
      targetMonths: targetMonths ?? this.targetMonths,
      dailyTargetPerVakit: dailyTargetPerVakit ?? this.dailyTargetPerVakit,
      estimatedFinishDate: estimatedFinishDate ?? this.estimatedFinishDate,
    );
  }

  @override
  List<Object?> get props =>
      [targetMonths, dailyTargetPerVakit, estimatedFinishDate];
}
