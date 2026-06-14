import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/utils/prayer_calculator.dart';
import 'package:kaza_takip/domain/entities/kaza_debt.dart';

part 'simulator_event.dart';
part 'simulator_state.dart';

class SimulatorBloc extends Bloc<SimulatorEvent, SimulatorState> {
  SimulatorBloc() : super(const SimulatorState()) {
    on<SimulatorDebtUpdated>(_onDebtUpdated);
    on<SimulatorDailyTargetChanged>(_onTargetChanged);
  }

  void _onDebtUpdated(
      SimulatorDebtUpdated event, Emitter<SimulatorState> emit) {
    emit(state.copyWith(kazaDebt: event.debt));
    _recalculate(emit);
  }

  void _onTargetChanged(
      SimulatorDailyTargetChanged event, Emitter<SimulatorState> emit) {
    emit(state.copyWith(dailyTarget: event.target));
    _recalculate(emit);
  }

  void _recalculate(Emitter<SimulatorState> emit) {
    if (state.kazaDebt == null) return;
    final completion = PrayerCalculator.estimateCompletionDate(
      remaining: state.kazaDebt!.remainingCounts,
      dailyTargetPerVakit: state.dailyTarget,
    );
    emit(state.copyWith(estimatedCompletionDate: completion));
  }
}
