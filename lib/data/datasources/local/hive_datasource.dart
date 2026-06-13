import 'package:hive_flutter/hive_flutter.dart';
import 'package:kaza_takip/core/constants/app_constants.dart';
import 'package:kaza_takip/data/models/kaza_debt_model.dart';
import 'package:kaza_takip/data/models/prayer_plan_model.dart';
import 'package:kaza_takip/data/models/user_profile_model.dart';

class HiveLocalDataSource {
  late Box<KazaDebtModel> _kazaBox;
  late Box<PrayerPlanModel> _planBox;
  late Box<UserProfileModel> _userBox;
  // Streak stored as simple primitives in a generic box.
  late Box<dynamic> _streakBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(KazaDebtModelAdapter());
    Hive.registerAdapter(PrayerSlotModelAdapter());
    Hive.registerAdapter(PrayerPlanModelAdapter());
    Hive.registerAdapter(UserProfileModelAdapter());

    _kazaBox = await Hive.openBox<KazaDebtModel>(AppConstants.hiveBoxKaza);
    _planBox = await Hive.openBox<PrayerPlanModel>(AppConstants.hiveBoxPlan);
    _userBox = await Hive.openBox<UserProfileModel>(AppConstants.hiveBoxUser);
    _streakBox = await Hive.openBox(AppConstants.hiveBoxStreak);
  }

  // ── KazaDebt ──────────────────────────────────────────────────────────────

  KazaDebtModel? getKazaDebt(String userId) =>
      _kazaBox.get(userId);

  Future<void> saveKazaDebt(KazaDebtModel model) =>
      _kazaBox.put(model.userId, model);

  // ── PrayerPlan ────────────────────────────────────────────────────────────

  PrayerPlanModel? getPlan(String key) => _planBox.get(key);

  Future<void> savePlan(String key, PrayerPlanModel model) =>
      _planBox.put(key, model);

  List<PrayerPlanModel> getAllPlans(String userId) =>
      _planBox.values.where((p) => p.userId == userId).toList();

  // ── UserProfile ───────────────────────────────────────────────────────────

  UserProfileModel? getUserProfile(String userId) => _userBox.get(userId);

  Future<void> saveUserProfile(UserProfileModel model) =>
      _userBox.put(model.id, model);

  // ── Streak ────────────────────────────────────────────────────────────────

  Map<String, dynamic>? getStreakData(String userId) {
    final raw = _streakBox.get('streak_$userId');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> saveStreakData(String userId, Map<String, dynamic> data) =>
      _streakBox.put('streak_$userId', data);

  // ── Pending sync counter ──────────────────────────────────────────────────

  int getPendingSyncCount(String userId) =>
      (_streakBox.get('pending_$userId') as int?) ?? 0;

  Future<void> incrementPendingSync(String userId) {
    final current = getPendingSyncCount(userId);
    return _streakBox.put('pending_$userId', current + 1);
  }

  Future<void> resetPendingSync(String userId) =>
      _streakBox.put('pending_$userId', 0);
}
