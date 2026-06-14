// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_plan_model.dart';

class UserPlanModelAdapter extends TypeAdapter<UserPlanModel> {
  @override
  final int typeId = 2;

  @override
  UserPlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPlanModel(
      targetMonths: fields[0] as int,
      dailyTargetPerVakit: fields[1] as int,
      estimatedFinishDate: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserPlanModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.targetMonths)
      ..writeByte(1)
      ..write(obj.dailyTargetPerVakit)
      ..writeByte(2)
      ..write(obj.estimatedFinishDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
