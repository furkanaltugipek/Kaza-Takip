import 'package:kaza_takip/core/constants/prayer_constants.dart';
import 'package:kaza_takip/core/utils/prayer_calculator.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/domain/entities/kaza_debt.dart';
import 'package:kaza_takip/domain/entities/prayer_plan.dart';
import 'package:kaza_takip/domain/repositories/kaza_repository.dart';
import 'package:uuid/uuid.dart';

class GetTodayPlan {
  final KazaRepository repository;
  GetTodayPlan(this.repository);

  Future<PrayerPlan> call({
    required String userId,
    required String mode,
    required KazaDebt debt,
  }) async {
    final existing = await repository.getTodayPlan(userId);
    if (existing != null &&
        AppDateUtils.isSameDay(existing.date, DateTime.now())) {
      return existing;
    }

    final targets = PrayerCalculator.dailyTargetsFromMode(mode);
    final slots = <PrayerSlot>[];

    for (final key in PrayerConstants.prayerKeys) {
      final count = targets[key] ?? 1;
      final remaining = debt.remainingCounts[key] ?? 0;
      final actualCount = count.clamp(0, remaining);
      for (int i = 0; i < actualCount; i++) {
        slots.add(PrayerSlot(
          slotId: const Uuid().v4(),
          prayerKey: key,
          kazaIndex: i + 1,
        ));
      }
    }

    final plan = PrayerPlan(
      id: const Uuid().v4(),
      userId: userId,
      date: AppDateUtils.today(),
      mode: mode,
      slots: slots,
    );

    await repository.savePlan(plan);
    return plan;
  }
}
