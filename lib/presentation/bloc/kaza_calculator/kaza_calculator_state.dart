part of 'kaza_calculator_bloc.dart';

enum KazaCalculatorStatus { initial, loading, success, failure }

class KazaCalculatorState extends Equatable {
  final KazaCalculatorStatus status;
  final DateTime? birthDate;
  final DateTime? pubertyDate;
  final DateTime? regularStartDate;
  final bool isFemale;
  final KazaDebt? result;
  final String? errorMessage;

  const KazaCalculatorState({
    this.status = KazaCalculatorStatus.initial,
    this.birthDate,
    this.pubertyDate,
    this.regularStartDate,
    this.isFemale = false,
    this.result,
    this.errorMessage,
  });

  bool get canSubmit =>
      birthDate != null && pubertyDate != null && regularStartDate != null;

  KazaCalculatorState copyWith({
    KazaCalculatorStatus? status,
    DateTime? birthDate,
    DateTime? pubertyDate,
    DateTime? regularStartDate,
    bool? isFemale,
    KazaDebt? result,
    String? errorMessage,
  }) {
    return KazaCalculatorState(
      status: status ?? this.status,
      birthDate: birthDate ?? this.birthDate,
      pubertyDate: pubertyDate ?? this.pubertyDate,
      regularStartDate: regularStartDate ?? this.regularStartDate,
      isFemale: isFemale ?? this.isFemale,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        birthDate,
        pubertyDate,
        regularStartDate,
        isFemale,
        result,
        errorMessage,
      ];
}
