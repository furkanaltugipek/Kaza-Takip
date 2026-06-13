import 'package:kaza_takip/core/utils/prayer_calculator.dart';
import 'package:kaza_takip/domain/entities/kaza_debt.dart';
import 'package:kaza_takip/domain/repositories/kaza_repository.dart';
import 'package:uuid/uuid.dart';

class CalculateKazaDebt {
  final KazaRepository repository;
  CalculateKazaDebt(this.repository);

  Future<KazaDebt> call({
    required String userId,
    required DateTime birthDate,
    required DateTime pubertyDate,
    required DateTime regularStartDate,
    required bool isFemale,
  }) async {
    final counts = PrayerCalculator.calculateKazaDebt(
      birthDate: birthDate,
      pubertyDate: pubertyDate,
      regularStartDate: regularStartDate,
      isFemale: isFemale,
    );

    final now = DateTime.now();
    final debt = KazaDebt(
      id: const Uuid().v4(),
      userId: userId,
      birthDate: birthDate,
      pubertyDate: pubertyDate,
      regularStartDate: regularStartDate,
      isFemale: isFemale,
      remainingCounts: counts,
      createdAt: now,
      updatedAt: now,
    );

    await repository.saveKazaDebt(debt);
    return debt;
  }
}
