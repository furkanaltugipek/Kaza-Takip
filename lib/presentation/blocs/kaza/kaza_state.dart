part of 'kaza_bloc.dart';

sealed class KazaState extends Equatable {
  const KazaState();
  @override
  List<Object?> get props => [];
}

/// Uygulama ilk açıldığında / veri yok iken.
class KazaInitial extends KazaState {
  const KazaInitial();
}

/// Hive okuma veya hesaplama sırasında.
class KazaLoading extends KazaState {
  const KazaLoading();
}

/// Sihirbaz hesaplamayı tamamladı — kullanıcıya gösterilecek önizleme.
/// Henüz kaydedilmedi; [SaveCalculatedDebt] ile Hive'a yazılır.
class KazaCalculated extends KazaState {
  /// Hesaplama motoru çıktısı.
  final KazaCalculationResult result;

  const KazaCalculated(this.result);
  @override
  List<Object?> get props => [result];
}

/// Ana Dashboard durumu — tüm veriler yüklü.
class KazaLoaded extends KazaState {
  final String userId;
  final KazaMetrics metrics;
  final DailyLog? todayLog;
  final UserPlan? userPlan;

  /// Güncel mod: 'EASY' | 'MEDIUM' | 'HARD'
  final String planMode;

  /// Senkronize edilmemiş yerel değişiklik sayısı.
  final int pendingChanges;

  const KazaLoaded({
    required this.userId,
    required this.metrics,
    this.todayLog,
    this.userPlan,
    this.planMode = 'MEDIUM',
    this.pendingChanges = 0,
  });

  /// Moda göre her vakit için günlük kaza hedefi.
  int get dailyTargetPerVakit => switch (planMode) {
        'EASY' => 1,
        'HARD' => 4,
        _ => 2, // MEDIUM
      };

  /// Bugünün o vakit için tamamlama sayısı.
  int completedTodayFor(String vakit) =>
      todayLog?.completedToday[vakit] ?? 0;

  KazaLoaded copyWith({
    KazaMetrics? metrics,
    DailyLog? todayLog,
    UserPlan? userPlan,
    String? planMode,
    int? pendingChanges,
  }) {
    return KazaLoaded(
      userId: userId,
      metrics: metrics ?? this.metrics,
      todayLog: todayLog ?? this.todayLog,
      userPlan: userPlan ?? this.userPlan,
      planMode: planMode ?? this.planMode,
      pendingChanges: pendingChanges ?? this.pendingChanges,
    );
  }

  @override
  List<Object?> get props =>
      [userId, metrics, todayLog, userPlan, planMode, pendingChanges];
}

class KazaError extends KazaState {
  final String message;
  const KazaError(this.message);
  @override
  List<Object?> get props => [message];
}
