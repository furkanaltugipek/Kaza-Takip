part of 'simulator_bloc.dart';

abstract class SimulatorEvent extends Equatable {
  const SimulatorEvent();
  @override
  List<Object?> get props => [];
}

class SimulatorDebtUpdated extends SimulatorEvent {
  final KazaDebt debt;
  const SimulatorDebtUpdated(this.debt);
  @override
  List<Object?> get props => [debt];
}

class SimulatorDailyTargetChanged extends SimulatorEvent {
  final int target;
  const SimulatorDailyTargetChanged(this.target);
  @override
  List<Object?> get props => [target];
}
