// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log_model.dart';

class DailyLogModelAdapter extends TypeAdapter<DailyLogModel> {
  @override
  final int typeId = 1;

  @override
  DailyLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLogModel(
      date: fields[0] as DateTime,
      status: fields[1] as String,
      completedToday: (fields[2] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyLogModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.completedToday);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
