import 'package:kaza_takip/data/datasources/local/hive_datasource.dart';

/// İbadet modülleri için hafif kalıcılık servisi.
///
/// Tüm değerler Hive'daki genel 'ibadet_box' içinde basit anahtar/değer
/// olarak saklanır — her gündelik etkileşim anlık ve ücretsizdir (ağ yok).
class IbadetService {
  final HiveLocalDataSource _local;
  IbadetService(this._local);

  // ── Oruç Kazası ─────────────────────────────────────────────────────────────

  int get fastingDebt => (_local.getIbadet('fasting_debt') as int?) ?? 0;
  int get fastingCompleted =>
      (_local.getIbadet('fasting_completed') as int?) ?? 0;

  Future<void> setFastingDebt(int value) =>
      _local.putIbadet('fasting_debt', value);

  Future<void> setFastingCompleted(int value) =>
      _local.putIbadet('fasting_completed', value.clamp(0, fastingDebt));

  // ── Hatim Takibi ────────────────────────────────────────────────────────────

  /// Kur'an toplam 604 sayfa / 30 cüzdür.
  static const int totalQuranPages = 604;

  int get hatimCurrentPage =>
      (_local.getIbadet('hatim_page') as int?) ?? 0;
  int get hatimCompletedCount =>
      (_local.getIbadet('hatim_count') as int?) ?? 0;

  Future<void> setHatimPage(int page) =>
      _local.putIbadet('hatim_page', page.clamp(0, totalQuranPages));

  Future<void> incrementHatimCount() =>
      _local.putIbadet('hatim_count', hatimCompletedCount + 1);

  // ── Zikirmatik ──────────────────────────────────────────────────────────────

  int dhikrCount(String dhikrKey) =>
      (_local.getIbadet('dhikr_$dhikrKey') as int?) ?? 0;

  Future<void> setDhikrCount(String dhikrKey, int value) =>
      _local.putIbadet('dhikr_$dhikrKey', value);

  // ── Sadaka Hedefleri ────────────────────────────────────────────────────────

  /// Sadaka kayıtları: her biri 'yyyy-MM-dd|açıklama' formatında string.
  List<String> get charityLog {
    final raw = _local.getIbadet('charity_log');
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return <String>[];
  }

  Future<void> addCharity(String entry) {
    final list = List<String>.from(charityLog)..insert(0, entry);
    return _local.putIbadet('charity_log', list);
  }

  Future<void> removeCharity(int index) {
    final list = List<String>.from(charityLog);
    if (index >= 0 && index < list.length) list.removeAt(index);
    return _local.putIbadet('charity_log', list);
  }
}
