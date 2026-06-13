part of 'simulator_bloc.dart';

class SimulatorState extends Equatable {
  final KazaDebt? kazaDebt;
  final int dailyTarget;
  final DateTime? estimatedCompletionDate;

  const SimulatorState({
    this.kazaDebt,
    this.dailyTarget = 1,
    this.estimatedCompletionDate,
  });

  SimulatorState copyWith({
    KazaDebt? kazaDebt,
    int? dailyTarget,
    DateTime? estimatedCompletionDate,
  }) {
    return SimulatorState(
      kazaDebt: kazaDebt ?? this.kazaDebt,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      estimatedCompletionDate:
          estimatedCompletionDate ?? this.estimatedCompletionDate,
    );
  }

  @override
  List<Object?> get props => [kazaDebt, dailyTarget, estimatedCompletionDate];
}
