class AppConstants {
  AppConstants._();

  static const String appName = 'Kaza Takip';
  static const String hiveBoxKaza = 'kaza_box';
  static const String hiveBoxUser = 'user_box';
  static const String hiveBoxPlan = 'plan_box';
  static const String hiveBoxStreak = 'streak_box';

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
