import 'package:kaza_takip/domain/entities/kaza_debt.dart';
import 'package:kaza_takip/domain/entities/prayer_plan.dart';
import 'package:kaza_takip/domain/entities/streak.dart';

abstract class KazaRepository {
  Future<KazaDebt?> getKazaDebt(String userId);
  Future<void> saveKazaDebt(KazaDebt debt);

  /// Decrement a single prayer's remaining count and create/update today's plan.
  Future<void> completePrayerSlot(String userId, String slotId);

  Future<PrayerPlan?> getTodayPlan(String userId);
  Future<void> savePlan(PrayerPlan plan);

  Future<Streak> getStreak(String userId);
  Future<void> saveStreak(Streak streak);

  /// Returns a map of date-string → completion ratio (0.0–1.0) for the calendar.
  Future<Map<String, double>> getCalendarData(
      String userId, DateTime month);

  /// Pushes locally cached changes to Firestore (batch call).
  Future<void> syncToRemote(String userId);
}
