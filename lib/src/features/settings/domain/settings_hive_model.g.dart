// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsHiveModelAdapter extends TypeAdapter<SettingsHiveModel> {
  @override
  final int typeId = 2;

  @override
  SettingsHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsHiveModel(
      currentThemeIndex: fields[0] as int,
      themeType: fields[1] as ThemeType,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.currentThemeIndex)
      ..writeByte(1)
      ..write(obj.themeType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
