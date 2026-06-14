class AppConstants {
  AppConstants._();

  static const String appName = 'Kaza Takip';
  static const String hiveBoxKaza = 'kaza_box';
  static const String hiveBoxUser = 'user_box';
  static const String hiveBoxPlan = 'plan_box';
  static const String hiveBoxStreak = 'streak_box';

  // Yeni veri katmanı kutuları (KazaMetrics / DailyLog / UserPlan)
  static const String hiveBoxMetrics = 'metrics_box';
  static const String hiveBoxDailyLog = 'daily_log_box';
  static const String hiveBoxUserPlan = 'user_plan_box';

  // İbadet modülleri (Oruç / Hatim / Zikir / Sadaka)
  static const String hiveBoxIbadet = 'ibadet_box';

  // Bildirim tercihleri (SharedPreferences anahtarları)
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefLatitude = 'pref_latitude';
  static const String prefLongitude = 'pref_longitude';

  // Varsayılan konum: İstanbul (konum izni yoksa kullanılır)
  static const double defaultLatitude = 41.0082;
  static const double defaultLongitude = 28.9784;

  // Firestore collections
  static const String colUsers = 'users';
  static const String colKazaDebts = 'kaza_debts';
  static const String colDailyPlans = 'daily_plans';

  // Batch sync: push to Firestore every N local changes
  static const int firestoreSyncThreshold = 10;

  // Daily plan modes
  static const String modeEasy = 'easy';
  static const String modeMedium = 'medium';
  static const String modeHard = 'hard';

  static const Map<String, int> modeMultipliers = {
    modeEasy: 1,
    modeMedium: 2,
    modeHard: 4,
  };
}
