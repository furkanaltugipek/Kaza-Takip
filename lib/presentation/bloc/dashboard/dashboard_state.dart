part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final PrayerPlan? todayPlan;
  final KazaDebt? kazaDebt;
  final Streak? streak;
  final String mode;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.todayPlan,
    this.kazaDebt,
    this.streak,
    this.mode = 'medium',
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    PrayerPlan? todayPlan,
    KazaDebt? kazaDebt,
    Streak? streak,
    String? mode,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      todayPlan: todayPlan ?? this.todayPlan,
      kazaDebt: kazaDebt ?? this.kazaDebt,
      streak: streak ?? this.streak,
      mode: mode ?? this.mode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, todayPlan, kazaDebt, streak, mode, errorMessage];
}
