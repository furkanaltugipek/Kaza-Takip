// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 3;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      id: fields[0] as String,
      displayName: fields[1] as String?,
      email: fields[2] as String?,
      isFemale: fields[3] as bool,
      dailyMode: fields[4] as String,
      isDarkMode: fields[5] as bool,
      notificationsEnabled: fields[6] as bool,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.isFemale)
      ..writeByte(4)
      ..write(obj.dailyMode)
      ..writeByte(5)
      ..write(obj.isDarkMode)
      ..writeByte(6)
      ..write(obj.notificationsEnabled)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
