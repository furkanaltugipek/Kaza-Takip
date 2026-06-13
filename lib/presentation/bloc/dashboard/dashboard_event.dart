part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class DashboardLoaded extends DashboardEvent {
  final String userId;
  const DashboardLoaded(this.userId);
  @override
  List<Object?> get props => [userId];
}

class DashboardPrayerCompleted extends DashboardEvent {
  final String slotId;
  const DashboardPrayerCompleted(this.slotId);
  @override
  List<Object?> get props => [slotId];
}

class DashboardModeChanged extends DashboardEvent {
  final String mode;
  const DashboardModeChanged(this.mode);
  @override
  List<Object?> get props => [mode];
}

class DashboardSyncRequested extends DashboardEvent {
  const DashboardSyncRequested();
}
