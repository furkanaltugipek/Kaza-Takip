import 'package:hive/hive.dart';
import 'package:kaza_takip/domain/entities/kaza_metrics.dart';

part 'kaza_metrics_model.g.dart';

/// Hive + JSON modeli — [KazaMetrics] domain entity'sine eşlenir.
///
/// Tek bir kullanıcı için toplam ve tamamlanan kaza borçlarını,
/// seri (streak) bilgisini saklar.
@HiveType(typeId: 0)
class KazaMetricsModel extends HiveObject {
  @HiveField(0) Map<String, int> totalDebts;
  @HiveField(1) Map<String, int> completedDebts;
  @HiveField(2) int currentStreak;
  @HiveField(3) int longestStreak;

  KazaMetricsModel({
    required this.totalDebts,
    required this.completedDebts,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  // ── Entity dönüşümleri ──────────────────────────────────────────────────────

  factory KazaMetricsModel.fromEntity(KazaMetrics e) => KazaMetricsModel(
        totalDebts: Map<String, int>.from(e.totalDebts),
        completedDebts: Map<String, int>.from(e.completedDebts),
        currentStreak: e.currentStreak,
        longestStreak: e.longestStreak,
      );

  KazaMetrics toEntity() => KazaMetrics(
        totalDebts: Map<String, int>.from(totalDebts),
        completedDebts: Map<String, int>.from(completedDebts),
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );

  // ── JSON / Firestore dönüşümleri ────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'totalDebts': totalDebts,
        'completedDebts': completedDebts,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };

  factory KazaMetricsModel.fromJson(Map<String, dynamic> json) =>
      KazaMetricsModel(
        totalDebts: _asIntMap(json['totalDebts']),
        completedDebts: _asIntMap(json['completedDebts']),
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      );

  static Map<String, int> _asIntMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }
    return <String, int>{};
  }
}
