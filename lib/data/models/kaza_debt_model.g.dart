// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build --delete-conflicting-outputs

part of 'kaza_debt_model.dart';

class KazaDebtModelAdapter extends TypeAdapter<KazaDebtModel> {
  @override
  final int typeId = 0;

  @override
  KazaDebtModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KazaDebtModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      birthDate: fields[2] as DateTime,
      pubertyDate: fields[3] as DateTime,
      regularStartDate: fields[4] as DateTime,
      isFemale: fields[5] as bool,
      remainingCounts: (fields[6] as Map).cast<String, int>(),
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, KazaDebtModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.birthDate)
      ..writeByte(3)
      ..write(obj.pubertyDate)
      ..writeByte(4)
      ..write(obj.regularStartDate)
      ..writeByte(5)
      ..write(obj.isFemale)
      ..writeByte(6)
      ..write(obj.remainingCounts)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KazaDebtModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
