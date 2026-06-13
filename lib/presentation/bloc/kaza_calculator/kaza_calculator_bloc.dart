import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/domain/entities/kaza_debt.dart';
import 'package:kaza_takip/domain/usecases/calculate_kaza_debt.dart';

part 'kaza_calculator_event.dart';
part 'kaza_calculator_state.dart';

class KazaCalculatorBloc
    extends Bloc<KazaCalculatorEvent, KazaCalculatorState> {
  final CalculateKazaDebt _calculateKazaDebt;
  late String _userId;

  KazaCalculatorBloc({required CalculateKazaDebt calculateKazaDebt})
      : _calculateKazaDebt = calculateKazaDebt,
        super(const KazaCalculatorState()) {
    on<KazaCalculatorStarted>(_onStarted);
    on<KazaBirthDateChanged>(_onBirthDateChanged);
    on<KazaPubertyDateChanged>(_onPubertyDateChanged);
    on<KazaRegularStartDateChanged>(_onRegularStartDateChanged);
    on<KazaGenderChanged>(_onGenderChanged);
    on<KazaCalculationSubmitted>(_onSubmitted);
  }

  void _onStarted(
      KazaCalculatorStarted event, Emitter<KazaCalculatorState> emit) {
    _userId = event.userId;
  }

  void _onBirthDateChanged(
      KazaBirthDateChanged event, Emitter<KazaCalculatorState> emit) {
    emit(state.copyWith(birthDate: event.date));
  }

  void _onPubertyDateChanged(
      KazaPubertyDateChanged event, Emitter<KazaCalculatorState> emit) {
    emit(state.copyWith(pubertyDate: event.date));
  }

  void _onRegularStartDateChanged(
      KazaRegularStartDateChanged event, Emitter<KazaCalculatorState> emit) {
    emit(state.copyWith(regularStartDate: event.date));
  }

  void _onGenderChanged(
      KazaGenderChanged event, Emitter<KazaCalculatorState> emit) {
    emit(state.copyWith(isFemale: event.isFemale));
  }

  Future<void> _onSubmitted(
      KazaCalculationSubmitted event, Emitter<KazaCalculatorState> emit) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: KazaCalculatorStatus.loading));
    try {
      final debt = await _calculateKazaDebt(
        userId: _userId,
        birthDate: state.birthDate!,
        pubertyDate: state.pubertyDate!,
        regularStartDate: state.regularStartDate!,
        isFemale: state.isFemale,
      );
      emit(state.copyWith(
        status: KazaCalculatorStatus.success,
        result: debt,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: KazaCalculatorStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
