// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_plan_model.dart';

class PrayerSlotModelAdapter extends TypeAdapter<PrayerSlotModel> {
  @override
  final int typeId = 1;

  @override
  PrayerSlotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerSlotModel(
      slotId: fields[0] as String,
      prayerKey: fields[1] as String,
      kazaIndex: fields[2] as int,
      isCompleted: fields[3] as bool,
      completedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerSlotModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.slotId)
      ..writeByte(1)
      ..write(obj.prayerKey)
      ..writeByte(2)
      ..write(obj.kazaIndex)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerSlotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrayerPlanModelAdapter extends TypeAdapter<PrayerPlanModel> {
  @override
  final int typeId = 2;

  @override
  PrayerPlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerPlanModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      mode: fields[3] as String,
      slots: (fields[4] as List).cast<PrayerSlotModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, PrayerPlanModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.mode)
      ..writeByte(4)
      ..write(obj.slots);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerPlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
