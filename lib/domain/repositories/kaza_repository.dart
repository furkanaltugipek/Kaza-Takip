import 'package:kaza_takip/domain/entities/daily_log.dart';
import 'package:kaza_takip/domain/entities/kaza_debt.dart';
import 'package:kaza_takip/domain/entities/kaza_metrics.dart';
import 'package:kaza_takip/domain/entities/prayer_plan.dart';
import 'package:kaza_takip/domain/entities/streak.dart';
import 'package:kaza_takip/domain/entities/user_plan.dart';

/// Kaza verisi için repository sözleşmesi.
///
/// Mimari kuralı (Offline-First):
///  - Tüm gündelik yazmalar SADECE Hive'a yazar (anlık, ücretsiz).
///  - [syncWithCloud] çağrıldığında biriken durum TEK bir batch ile
///    Firestore'a gönderilir. Her tıklamada ağ çağrısı YAPILMAZ.
abstract class KazaRepository {
  // ── Yeni veri katmanı API'si (KazaMetrics / DailyLog / UserPlan) ────────────

  /// Kullanıcının güncel metriklerini döndürür (yoksa boş metrik).
  Future<KazaMetrics> getMetrics(String userId);

  /// Bir vakit için [delta] kadar kaza tamamlandığını işler.
  /// Sadece Hive'a yazar; bulut senkronu [syncWithCloud] ile yapılır.
  Future<KazaMetrics> updateKazaProgress({
    required String userId,
    required String vakitKey,
    int delta = 1,
  });

  /// İlk hesaplama sonrası toplam borçları kaydeder.
  Future<void> saveMetrics(String userId, KazaMetrics metrics);

  /// Bir günün kaydını yerel olarak saklar (anlık).
  Future<void> saveDailyLog(String userId, DailyLog log);

  /// Belirli bir ayın günlük kayıtlarını döndürür (katkı takvimi için).
  Future<List<DailyLog>> getDailyLogs(String userId, DateTime month);

  Future<UserPlan?> getUserPlan(String userId);
  Future<void> saveUserPlan(String userId, UserPlan plan);

  /// Biriken yerel durumu TEK batch ile Firestore'a gönderir.
  Future<void> syncWithCloud(String userId);

  /// Henüz buluta gönderilmemiş yerel değişiklik sayısı.
  int pendingChanges(String userId);

  // ── Geriye dönük uyumluluk (eski presentation katmanı için) ─────────────────
  // Not: Bu metotlar Adım 4'te yeni API'ye taşındığında kaldırılacaktır.

  Future<KazaDebt?> getKazaDebt(String userId);
  Future<void> saveKazaDebt(KazaDebt debt);
  Future<void> completePrayerSlot(String userId, String slotId);
  Future<PrayerPlan?> getTodayPlan(String userId);
  Future<void> savePlan(PrayerPlan plan);
  Future<Streak> getStreak(String userId);
  Future<void> saveStreak(Streak streak);
  Future<Map<String, double>> getCalendarData(String userId, DateTime month);
  Future<void> syncToRemote(String userId);
}
