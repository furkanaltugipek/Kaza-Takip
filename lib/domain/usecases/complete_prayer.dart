import 'package:kaza_takip/domain/entities/kaza_debt.dart';
import 'package:kaza_takip/domain/entities/prayer_plan.dart';
import 'package:kaza_takip/domain/entities/streak.dart';
import 'package:kaza_takip/domain/repositories/kaza_repository.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';

class CompletePrayer {
  final KazaRepository repository;
  CompletePrayer(this.repository);

  /// Marks a slot as done, decrements kaza debt, and updates streak.
  Future<({PrayerPlan plan, KazaDebt debt, Streak streak})> call({
    required String userId,
    required PrayerPlan plan,
    required KazaDebt debt,
    required Streak streak,
    required String slotId,
  }) async {
    // 1. Mark slot completed
    final updatedSlots = plan.slots.map((s) {
      if (s.slotId == slotId) {
        return s.copyWith(isCompleted: true, completedAt: DateTime.now());
      }
      return s;
    }).toList();
    final updatedPlan = plan.copyWith(slots: updatedSlots);

    // 2. Decrement remaining count for that prayer key
    final slot = plan.slots.firstWhere((s) => s.slotId == slotId);
    final newCounts = Map<String, int>.from(debt.remainingCounts);
    newCounts[slot.prayerKey] =
        ((newCounts[slot.prayerKey] ?? 0) - 1).clamp(0, 999999);
    final updatedDebt = debt.copyWith(
      remainingCounts: newCounts,
      updatedAt: DateTime.now(),
    );

    // 3. Update streak if plan is now fully completed
    Streak updatedStreak = streak;
    if (updatedPlan.isFullyCompleted) {
      updatedStreak = _updateStreak(streak);
    }

    // Persist locally (Firestore sync happens in batch later)
    await Future.wait([
      repository.savePlan(updatedPlan),
      repository.saveKazaDebt(updatedDebt),
      repository.saveStreak(updatedStreak),
    ]);

    return (plan: updatedPlan, debt: updatedDebt, streak: updatedStreak);
  }

  Streak _updateStreak(Streak current) {
    final today = AppDateUtils.today();
    if (current.lastCompletedDate != null &&
        AppDateUtils.isSameDay(current.lastCompletedDate!, today)) {
      return current; // already counted today
    }

    final yesterday = AppDateUtils.yesterday();
    final isConsecutive = current.lastCompletedDate != null &&
        AppDateUtils.isSameDay(current.lastCompletedDate!, yesterday);

    final newStreak = isConsecutive ? current.currentStreak + 1 : 1;
    return current.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > current.longestStreak
          ? newStreak
          : current.longestStreak,
      lastCompletedDate: today,
      totalCompletedDays: current.totalCompletedDays + 1,
    );
  }
}
