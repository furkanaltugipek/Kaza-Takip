import 'package:hive/hive.dart';
import 'package:kaza_takip/domain/entities/prayer_plan.dart';

part 'prayer_plan_model.g.dart';

@HiveType(typeId: 11)
class PrayerSlotModel extends HiveObject {
  @HiveField(0) String slotId;
  @HiveField(1) String prayerKey;
  @HiveField(2) int kazaIndex;
  @HiveField(3) bool isCompleted;
  @HiveField(4) DateTime? completedAt;

  PrayerSlotModel({
    required this.slotId,
    required this.prayerKey,
    required this.kazaIndex,
    required this.isCompleted,
    this.completedAt,
  });

  factory PrayerSlotModel.fromEntity(PrayerSlot e) => PrayerSlotModel(
        slotId: e.slotId,
        prayerKey: e.prayerKey,
        kazaIndex: e.kazaIndex,
        isCompleted: e.isCompleted,
        completedAt: e.completedAt,
      );

  PrayerSlot toEntity() => PrayerSlot(
        slotId: slotId,
        prayerKey: prayerKey,
        kazaIndex: kazaIndex,
        isCompleted: isCompleted,
        completedAt: completedAt,
      );
}

@HiveType(typeId: 12)
class PrayerPlanModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String userId;
  @HiveField(2) DateTime date;
  @HiveField(3) String mode;
  @HiveField(4) List<PrayerSlotModel> slots;

  PrayerPlanModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mode,
    required this.slots,
  });

  factory PrayerPlanModel.fromEntity(PrayerPlan e) => PrayerPlanModel(
        id: e.id,
        userId: e.userId,
        date: e.date,
        mode: e.mode,
        slots: e.slots.map(PrayerSlotModel.fromEntity).toList(),
      );

  PrayerPlan toEntity() => PrayerPlan(
        id: id,
        userId: userId,
        date: date,
        mode: mode,
        slots: slots.map((s) => s.toEntity()).toList(),
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'mode': mode,
        'slots': slots
            .map((s) => {
                  'slotId': s.slotId,
                  'prayerKey': s.prayerKey,
                  'kazaIndex': s.kazaIndex,
                  'isCompleted': s.isCompleted,
                  'completedAt': s.completedAt?.toIso8601String(),
                })
            .toList(),
      };
}
