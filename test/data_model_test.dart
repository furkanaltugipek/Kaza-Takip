import 'package:flutter_test/flutter_test.dart';
import 'package:kaza_takip/data/models/kaza_metrics_model.dart';
import 'package:kaza_takip/data/models/daily_log_model.dart';
import 'package:kaza_takip/data/models/user_plan_model.dart';
import 'package:kaza_takip/domain/entities/kaza_metrics.dart';
import 'package:kaza_takip/domain/entities/daily_log.dart';
import 'package:kaza_takip/domain/entities/user_plan.dart';

void main() {
  group('KazaMetricsModel dönüşümleri', () {
    final entity = const KazaMetrics(
      totalDebts: {'fajr': 100, 'witr': 100},
      completedDebts: {'fajr': 10, 'witr': 5},
      currentStreak: 3,
      longestStreak: 7,
    );

    test('entity -> model -> entity korunur', () {
      final back = KazaMetricsModel.fromEntity(entity).toEntity();
      expect(back.totalDebts, entity.totalDebts);
      expect(back.completedDebts, entity.completedDebts);
      expect(back.currentStreak, 3);
      expect(back.longestStreak, 7);
    });

    test('JSON round-trip korunur', () {
      final json = KazaMetricsModel.fromEntity(entity).toJson();
      final back = KazaMetricsModel.fromJson(json).toEntity();
      expect(back.completedDebts['fajr'], 10);
      expect(back.totalRemaining, entity.totalRemaining);
    });
  });

  group('DailyLogModel dönüşümleri', () {
    test('fromCounts ile status COMPLETED türetilir', () {
      final log = DailyLog.fromCounts(
        date: DateTime(2026, 6, 13),
        completedToday: {'fajr': 2, 'dhuhr': 2},
        targetCount: 4,
      );
      expect(log.status, 'COMPLETED');
      final back = DailyLogModel.fromEntity(log).toEntity();
      expect(back.statusEnum, DailyStatus.completed);
      expect(back.totalCompleted, 4);
    });

    test('dateKey yyyy-MM-dd formatında', () {
      final model = DailyLogModel.fromEntity(
        DailyLog.fromCounts(
          date: DateTime(2026, 1, 5),
          completedToday: const {},
          targetCount: 6,
        ),
      );
      expect(model.dateKey, '2026-01-05');
    });
  });

  group('UserPlanModel dönüşümleri', () {
    test('JSON round-trip korunur', () {
      final plan = UserPlan(
        targetMonths: 6,
        dailyTargetPerVakit: 3,
        estimatedFinishDate: DateTime(2027, 1, 1),
      );
      final back =
          UserPlanModel.fromJson(UserPlanModel.fromEntity(plan).toJson())
              .toEntity();
      expect(back.targetMonths, 6);
      expect(back.dailyTargetPerVakit, 3);
      expect(back.estimatedFinishDate, DateTime(2027, 1, 1));
    });
  });
}
