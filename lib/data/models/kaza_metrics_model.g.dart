// GENERATED CODE - DO NOT MODIFY BY HAND
// Çalıştır: flutter pub run build_runner build --delete-conflicting-outputs

part of 'kaza_metrics_model.dart';

class KazaMetricsModelAdapter extends TypeAdapter<KazaMetricsModel> {
  @override
  final int typeId = 0;

  @override
  KazaMetricsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KazaMetricsModel(
      totalDebts: (fields[0] as Map).cast<String, int>(),
      completedDebts: (fields[1] as Map).cast<String, int>(),
      currentStreak: fields[2] as int,
      longestStreak: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, KazaMetricsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalDebts)
      ..writeByte(1)
      ..write(obj.completedDebts)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.longestStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KazaMetricsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
