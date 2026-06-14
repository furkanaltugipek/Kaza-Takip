part of 'kaza_bloc.dart';

/// Tüm uygulama genelinde tek BLoC — kaza metrik yönetimi.
abstract class KazaEvent extends Equatable {
  const KazaEvent();
  @override
  List<Object?> get props => [];
}

/// Sihirbazdan ilk borç hesabını başlatır.
class CalculateInitialDebt extends KazaEvent {
  final DateTime birthDate;
  final int? pubertyAge;       // null → varsayılan 13
  final DateTime startDate;    // Düzenli namaza başlama tarihi
  final int offDays;           // Tahmin edilen mazeret günleri

  const CalculateInitialDebt({
    required this.birthDate,
    this.pubertyAge,
    required this.startDate,
    this.offDays = 0,
  });

  @override
  List<Object?> get props => [birthDate, pubertyAge, startDate, offDays];
}

/// Hesaplama sonuçlarını kaydedip Dashboard'a geçer.
class SaveCalculatedDebt extends KazaEvent {
  const SaveCalculatedDebt();
}

/// Hive'dan güncel metrikleri yükler.
class LoadKazaMetrics extends KazaEvent {
  final String userId;
  const LoadKazaMetrics(this.userId);
  @override
  List<Object?> get props => [userId];
}

/// Bir vakit için tamamlama kaydeder (+1) ya da geri alır (−1).
class TogglePrayerComplete extends KazaEvent {
  final String prayerVakit;   // fajr | dhuhr | asr | maghrib | isha | witr
  final int amount;           // +1 tamamla, -1 geri al

  const TogglePrayerComplete(this.prayerVakit, {this.amount = 1});
  @override
  List<Object?> get props => [prayerVakit, amount];
}

/// Mod değişikliği: 'EASY' | 'MEDIUM' | 'HARD'
class ChangePlanMode extends KazaEvent {
  final String mode;
  const ChangePlanMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

/// Biriken yerel değişiklikleri Firestore'a batch gönderir.
class SyncDataWithCloud extends KazaEvent {
  const SyncDataWithCloud();
}
