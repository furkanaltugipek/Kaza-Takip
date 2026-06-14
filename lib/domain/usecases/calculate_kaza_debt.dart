import 'package:kaza_takip/core/constants/prayer_constants.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
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
    int extraOffDays = 0,
  }) async {
    final pubertyAge = AppDateUtils.yearsBetween(birthDate, pubertyDate);

    // Female: exclude menstrual days across the debt window (~7 days/month).
    int estimatedOffDays = extraOffDays;
    if (isFemale) {
      final months = regularStartDate.difference(pubertyDate).inDays / 30.4375;
      estimatedOffDays +=
          (months * PrayerConstants.avgMenstrualDaysPerMonth).round();
    }

    final result = PrayerCalculator.calculate(
      birthDate: birthDate,
      pubertyAge: pubertyAge,
      prayerStartDate: regularStartDate,
      estimatedOffDays: estimatedOffDays,
    );
    final counts = result.breakdown;

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
