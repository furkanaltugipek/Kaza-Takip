import 'package:hive_flutter/hive_flutter.dart';
import 'package:kaza_takip/core/constants/app_constants.dart';
import 'package:kaza_takip/data/models/daily_log_model.dart';
import 'package:kaza_takip/data/models/kaza_debt_model.dart';
import 'package:kaza_takip/data/models/kaza_metrics_model.dart';
import 'package:kaza_takip/data/models/prayer_plan_model.dart';
import 'package:kaza_takip/data/models/user_plan_model.dart';
import 'package:kaza_takip/data/models/user_profile_model.dart';

class HiveLocalDataSource {
  // Yeni veri katmanı kutuları
  late Box<KazaMetricsModel> _metricsBox;
  late Box<DailyLogModel> _dailyLogBox;
  late Box<UserPlanModel> _userPlanBox;

  // Eski (geriye dönük) kutular
  late Box<KazaDebtModel> _kazaBox;
  late Box<PrayerPlanModel> _planBox;
  late Box<UserProfileModel> _userBox;
  // Streak ve sayaç gibi basit primitifler için genel kutu.
  late Box<dynamic> _streakBox;
  // İbadet modülleri için genel kutu (Oruç/Hatim/Zikir/Sadaka).
  late Box<dynamic> _ibadetBox;
  // Aladhan'dan çekilen aylık vakit dizileri (JSON string olarak saklanır).
  late Box<String> _prayerTimesBox;

  Future<void> init() async {
    await Hive.initFlutter();

    // Yeni adapter'lar (typeId 0,1,2)
    Hive.registerAdapter(KazaMetricsModelAdapter());
    Hive.registerAdapter(DailyLogModelAdapter());
    Hive.registerAdapter(UserPlanModelAdapter());

    // Eski adapter'lar (typeId 10,11,12,13)
    Hive.registerAdapter(KazaDebtModelAdapter());
    Hive.registerAdapter(PrayerSlotModelAdapter());
    Hive.registerAdapter(PrayerPlanModelAdapter());
    Hive.registerAdapter(UserProfileModelAdapter());

    _metricsBox =
        await Hive.openBox<KazaMetricsModel>(AppConstants.hiveBoxMetrics);
    _dailyLogBox =
        await Hive.openBox<DailyLogModel>(AppConstants.hiveBoxDailyLog);
    _userPlanBox =
        await Hive.openBox<UserPlanModel>(AppConstants.hiveBoxUserPlan);

    _kazaBox = await Hive.openBox<KazaDebtModel>(AppConstants.hiveBoxKaza);
    _planBox = await Hive.openBox<PrayerPlanModel>(AppConstants.hiveBoxPlan);
    _userBox = await Hive.openBox<UserProfileModel>(AppConstants.hiveBoxUser);
    _streakBox = await Hive.openBox(AppConstants.hiveBoxStreak);
    _ibadetBox = await Hive.openBox(AppConstants.hiveBoxIbadet);
    _prayerTimesBox =
        await Hive.openBox<String>(AppConstants.hiveBoxPrayerTimes);
  }

  // ── Namaz vakti aylık önbelleği ─────────────────────────────────────────────

  /// Anahtar formatı: '<cityLowercase>_<yyyy-MM>' → ayın JSON listesi.
  String? getPrayerTimesRaw(String key) => _prayerTimesBox.get(key);

  Future<void> putPrayerTimesRaw(String key, String jsonString) =>
      _prayerTimesBox.put(key, jsonString);

  /// Belirli bir şehrin tüm aylarını siler — şehir değişiminde çağrılır.
  Future<void> clearPrayerTimesForCity(String cityKey) async {
    final prefix = '${cityKey}_';
    final keysToDelete = _prayerTimesBox.keys
        .whereType<String>()
        .where((k) => k.startsWith(prefix))
        .toList();
    if (keysToDelete.isNotEmpty) {
      await _prayerTimesBox.deleteAll(keysToDelete);
    }
  }

  // ── İbadet modülleri (genel anahtar/değer deposu) ───────────────────────────

  dynamic getIbadet(String key) => _ibadetBox.get(key);

  Future<void> putIbadet(String key, dynamic value) =>
      _ibadetBox.put(key, value);

  // ── KazaMetrics ─────────────────────────────────────────────────────────────

  KazaMetricsModel? getMetrics(String userId) => _metricsBox.get(userId);

  Future<void> saveMetrics(String userId, KazaMetricsModel model) =>
      _metricsBox.put(userId, model);

  // ── DailyLog ────────────────────────────────────────────────────────────────

  /// Anahtar formatı: '<userId>_<yyyy-MM-dd>'
  Future<void> saveDailyLog(String key, DailyLogModel model) =>
      _dailyLogBox.put(key, model);

  DailyLogModel? getDailyLog(String key) => _dailyLogBox.get(key);

  /// Anahtarı '<userId>_' ile başlayan tüm günlük kayıtları döndürür.
  List<DailyLogModel> getDailyLogsForUser(String userId) {
    final prefix = '${userId}_';
    return _dailyLogBox.keys
        .whereType<String>()
        .where((k) => k.startsWith(prefix))
        .map((k) => _dailyLogBox.get(k))
        .whereType<DailyLogModel>()
        .toList();
  }

  // ── UserPlan ────────────────────────────────────────────────────────────────

  UserPlanModel? getUserPlan(String userId) => _userPlanBox.get(userId);

  Future<void> saveUserPlan(String userId, UserPlanModel model) =>
      _userPlanBox.put(userId, model);

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
