part of 'kaza_calculator_bloc.dart';

abstract class KazaCalculatorEvent extends Equatable {
  const KazaCalculatorEvent();
  @override
  List<Object?> get props => [];
}

class KazaCalculatorStarted extends KazaCalculatorEvent {
  final String userId;
  const KazaCalculatorStarted(this.userId);
  @override
  List<Object?> get props => [userId];
}

class KazaBirthDateChanged extends KazaCalculatorEvent {
  final DateTime date;
  const KazaBirthDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class KazaPubertyDateChanged extends KazaCalculatorEvent {
  final DateTime date;
  const KazaPubertyDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class KazaRegularStartDateChanged extends KazaCalculatorEvent {
  final DateTime date;
  const KazaRegularStartDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class KazaGenderChanged extends KazaCalculatorEvent {
  final bool isFemale;
  const KazaGenderChanged(this.isFemale);
  @override
  List<Object?> get props => [isFemale];
}

class KazaCalculationSubmitted extends KazaCalculatorEvent {
  const KazaCalculationSubmitted();
}
