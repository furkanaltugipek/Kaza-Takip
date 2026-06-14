import 'package:kaza_takip/core/constants/app_constants.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/data/datasources/local/hive_datasource.dart';
import 'package:kaza_takip/data/datasources/remote/firestore_datasource.dart';
import 'package:kaza_takip/data/models/daily_log_model.dart';
import 'package:kaza_takip/data/models/kaza_debt_model.dart';
import 'package:kaza_takip/data/models/kaza_metrics_model.dart';
import 'package:kaza_takip/data/models/prayer_plan_model.dart';
import 'package:kaza_takip/data/models/user_plan_model.dart';
import 'package:kaza_takip/domain/entities/daily_log.dart';
import 'package:kaza_takip/domain/entities/kaza_debt.dart';
import 'package:kaza_takip/domain/entities/kaza_metrics.dart';
import 'package:kaza_takip/domain/entities/prayer_plan.dart';
import 'package:kaza_takip/domain/entities/streak.dart';
import 'package:kaza_takip/domain/entities/user_plan.dart';
import 'package:kaza_takip/domain/repositories/kaza_repository.dart';

class KazaRepositoryImpl implements KazaRepository {
  final HiveLocalDataSource local;
  final FirestoreDataSource remote;

  KazaRepositoryImpl({required this.local, required this.remote});

  // ══════════════════════════════════════════════════════════════════════════
  // YENİ VERİ KATMANI API'si — Offline-First + Batch Sync
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<KazaMetrics> getMetrics(String userId) async {
    final model = local.getMetrics(userId);
    return model?.toEntity() ?? KazaMetrics.empty();
  }

  @override
  Future<void> saveMetrics(String userId, KazaMetrics metrics) async {
    // SADECE Hive — anlık ve ücretsiz.
    await local.saveMetrics(userId, KazaMetricsModel.fromEntity(metrics));
    await local.incrementPendingSync(userId);
  }

  @override
  Future<KazaMetrics> updateKazaProgress({
    required String userId,
    required String vakitKey,
    int delta = 1,
  }) async {
    final current = await getMetrics(userId);
    final completed = Map<String, int>.from(current.completedDebts);
    final total = current.totalDebts[vakitKey] ?? 0;
    final newValue = ((completed[vakitKey] ?? 0) + delta).clamp(0, total);
    completed[vakitKey] = newValue;

    final updated = current.copyWith(completedDebts: completed);

    // SADECE Hive'a yaz; bulut senkronu syncWithCloud() ile.
    await local.saveMetrics(userId, KazaMetricsModel.fromEntity(updated));
    await local.incrementPendingSync(userId);
    return updated;
  }

  @override
  Future<void> saveDailyLog(String userId, DailyLog log) async {
    final key = '${userId}_${AppDateUtils.toStorage(log.date)}';
    await local.saveDailyLog(key, DailyLogModel.fromEntity(log));
    await local.incrementPendingSync(userId);
  }

  @override
  Future<List<DailyLog>> getDailyLogs(String userId, DateTime month) async {
    final models = local.getDailyLogsForUser(userId);
    return models
        .where((m) => m.date.year == month.year && m.date.month == month.month)
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<UserPlan?> getUserPlan(String userId) async =>
      local.getUserPlan(userId)?.toEntity();

  @override
  Future<void> saveUserPlan(String userId, UserPlan plan) async {
    await local.saveUserPlan(userId, UserPlanModel.fromEntity(plan));
    await local.incrementPendingSync(userId);
  }

  @override
  int pendingChanges(String userId) => local.getPendingSyncCount(userId);

  @override
  Future<void> syncWithCloud(String userId) async {
    // Biriken TÜM yerel durumu TEK batch ile gönder.
    final metrics = local.getMetrics(userId);
    final plan = local.getUserPlan(userId);
    final logs = local.getDailyLogsForUser(userId);

    await remote.syncUserData(
      userId: userId,
      metrics: metrics,
      plan: plan,
      dailyLogs: logs,
    );

    await local.resetPendingSync(userId);
  }

  @override
  Future<KazaDebt?> getKazaDebt(String userId) async {
    final model = local.getKazaDebt(userId);
    return model?.toEntity();
  }

  @override
  Future<void> saveKazaDebt(KazaDebt debt) async {
    final model = KazaDebtModel.fromEntity(debt);
    await local.saveKazaDebt(model);
    await local.incrementPendingSync(debt.userId);
    await _maybeSyncToRemote(debt.userId);
  }

  @override
  Future<PrayerPlan?> getTodayPlan(String userId) async {
    final key = '${userId}_${AppDateUtils.toStorage(AppDateUtils.today())}';
    final model = local.getPlan(key);
    return model?.toEntity();
  }

  @override
  Future<void> savePlan(PrayerPlan plan) async {
    final key =
        '${plan.userId}_${AppDateUtils.toStorage(plan.date)}';
    final model = PrayerPlanModel.fromEntity(plan);
    await local.savePlan(key, model);
    await local.incrementPendingSync(plan.userId);
    await _maybeSyncToRemote(plan.userId);
  }

  @override
  Future<void> completePrayerSlot(String userId, String slotId) async {
    // Handled via savePlan after mutation in use case
  }

  @override
  Future<Streak> getStreak(String userId) async {
    final data = local.getStreakData(userId);
    if (data == null) return Streak(userId: userId);
    return Streak(
      userId: userId,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastCompletedDate: data['lastCompletedDate'] != null
          ? DateTime.parse(data['lastCompletedDate'] as String)
          : null,
      totalCompletedDays: data['totalCompletedDays'] as int? ?? 0,
    );
  }

  @override
  Future<void> saveStreak(Streak streak) async {
    await local.saveStreakData(streak.userId, {
      'currentStreak': streak.currentStreak,
      'longestStreak': streak.longestStreak,
      'lastCompletedDate': streak.lastCompletedDate?.toIso8601String(),
      'totalCompletedDays': streak.totalCompletedDays,
    });
  }

  @override
  Future<Map<String, double>> getCalendarData(
      String userId, DateTime month) async {
    // Build from local plans first; supplement with remote if needed.
    final allPlans = local.getAllPlans(userId);
    final result = <String, double>{};
    for (final plan in allPlans) {
      if (plan.date.year == month.year && plan.date.month == month.month) {
        final key = AppDateUtils.toStorage(plan.date);
        final slots = plan.slots;
        if (slots.isEmpty) continue;
        result[key] =
            slots.where((s) => s.isCompleted).length / slots.length;
      }
    }
    // If we have no local data, fall back to remote.
    if (result.isEmpty) {
      return remote.getCalendarData(userId, month);
    }
    return result;
  }

  @override
  Future<void> syncToRemote(String userId) async {
    final debt = local.getKazaDebt(userId);
    if (debt != null) await remote.syncKazaDebt(debt);

    final plans = local.getAllPlans(userId);
    if (plans.isNotEmpty) await remote.syncDailyPlans(userId, plans);

    await local.resetPendingSync(userId);
  }

  Future<void> _maybeSyncToRemote(String userId) async {
    final pending = local.getPendingSyncCount(userId);
    if (pending >= AppConstants.firestoreSyncThreshold) {
      await syncToRemote(userId);
    }
  }
}
