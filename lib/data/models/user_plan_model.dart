import 'package:hive/hive.dart';
import 'package:kaza_takip/domain/entities/user_plan.dart';

part 'user_plan_model.g.dart';

/// Hive + JSON modeli — [UserPlan] domain entity'sine eşlenir.
///
/// Kullanıcının seçtiği tempo: hedef ay sayısı, her vakit için günlük hedef
/// ve tahmini bitiş tarihi.
@HiveType(typeId: 2)
class UserPlanModel extends HiveObject {
  @HiveField(0) int targetMonths;
  @HiveField(1) int dailyTargetPerVakit;
  @HiveField(2) DateTime estimatedFinishDate;

  UserPlanModel({
    required this.targetMonths,
    required this.dailyTargetPerVakit,
    required this.estimatedFinishDate,
  });

  // ── Entity dönüşümleri ──────────────────────────────────────────────────────

  factory UserPlanModel.fromEntity(UserPlan e) => UserPlanModel(
        targetMonths: e.targetMonths,
        dailyTargetPerVakit: e.dailyTargetPerVakit,
        estimatedFinishDate: e.estimatedFinishDate,
      );

  UserPlan toEntity() => UserPlan(
        targetMonths: targetMonths,
        dailyTargetPerVakit: dailyTargetPerVakit,
        estimatedFinishDate: estimatedFinishDate,
      );

  // ── JSON / Firestore dönüşümleri ────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'targetMonths': targetMonths,
        'dailyTargetPerVakit': dailyTargetPerVakit,
        'estimatedFinishDate': estimatedFinishDate.toIso8601String(),
      };

  factory UserPlanModel.fromJson(Map<String, dynamic> json) => UserPlanModel(
        targetMonths: (json['targetMonths'] as num?)?.toInt() ?? 12,
        dailyTargetPerVakit:
            (json['dailyTargetPerVakit'] as num?)?.toInt() ?? 1,
        estimatedFinishDate: json['estimatedFinishDate'] != null
            ? DateTime.parse(json['estimatedFinishDate'] as String)
            : DateTime.now(),
      );
}
