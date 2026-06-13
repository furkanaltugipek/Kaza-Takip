import 'package:equatable/equatable.dart';

/// Represents one day's kaza plan — a list of prayer slots to complete.
class PrayerPlan extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String mode; // easy | medium | hard
  final List<PrayerSlot> slots;

  int get completedCount => slots.where((s) => s.isCompleted).length;
  int get totalCount => slots.length;
  bool get isFullyCompleted => completedCount == totalCount;
  double get completionRatio =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  const PrayerPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.mode,
    required this.slots,
  });

  PrayerPlan copyWith({List<PrayerSlot>? slots}) {
    return PrayerPlan(
      id: id,
      userId: userId,
      date: date,
      mode: mode,
      slots: slots ?? this.slots,
    );
  }

  @override
  List<Object?> get props => [id, date, slots];
}

class PrayerSlot extends Equatable {
  final String slotId;
  final String prayerKey; // fajr | dhuhr | asr | maghrib | isha | witr
  final int kazaIndex;    // 1st, 2nd… extra for today
  final bool isCompleted;
  final DateTime? completedAt;

  const PrayerSlot({
    required this.slotId,
    required this.prayerKey,
    required this.kazaIndex,
    this.isCompleted = false,
    this.completedAt,
  });

  PrayerSlot copyWith({bool? isCompleted, DateTime? completedAt}) {
    return PrayerSlot(
      slotId: slotId,
      prayerKey: prayerKey,
      kazaIndex: kazaIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [slotId, prayerKey, kazaIndex, isCompleted];
}
