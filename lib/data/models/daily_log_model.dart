import 'package:hive/hive.dart';
import 'package:kaza_takip/domain/entities/daily_log.dart';

part 'daily_log_model.g.dart';

/// Hive + JSON modeli — [DailyLog] domain entity'sine eşlenir.
///
/// Belirli bir günde tamamlanan kaza namazlarını ve günün durumunu saklar.
/// Katkı takvimi (GitHub tarzı) ve seri mantığı bu kayıtlardan beslenir.
@HiveType(typeId: 1)
class DailyLogModel extends HiveObject {
  @HiveField(0) DateTime date;
  @HiveField(1) String status; // COMPLETED | PARTIAL | NONE
  @HiveField(2) Map<String, int> completedToday;

  DailyLogModel({
    required this.date,
    required this.status,
    required this.completedToday,
  });

  // ── Entity dönüşümleri ──────────────────────────────────────────────────────

  factory DailyLogModel.fromEntity(DailyLog e) => DailyLogModel(
        date: DateTime(e.date.year, e.date.month, e.date.day),
        status: e.status,
        completedToday: Map<String, int>.from(e.completedToday),
      );

  DailyLog toEntity() => DailyLog(
        date: date,
        status: status,
        completedToday: Map<String, int>.from(completedToday),
      );

  // ── JSON / Firestore dönüşümleri ────────────────────────────────────────────

  /// Belge anahtarı olarak kullanılan tarih (yyyy-MM-dd).
  String get dateKey => date.toIso8601String().substring(0, 10);

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'status': status,
        'completedToday': completedToday,
      };

  factory DailyLogModel.fromJson(Map<String, dynamic> json) => DailyLogModel(
        date: DateTime.parse(json['date'] as String),
        status: json['status'] as String? ?? 'NONE',
        completedToday: (json['completedToday'] as Map?)
                ?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ??
            <String, int>{},
      );
}
