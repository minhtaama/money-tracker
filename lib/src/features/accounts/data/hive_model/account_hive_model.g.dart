// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountHiveModelAdapter extends TypeAdapter<AccountHiveModel> {
  @override
  final int typeId = 0;

  @override
  AccountHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountHiveModel(
      id: fields[0] as String,
      icon: fields[1] as String,
      name: fields[2] as String,
      color: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AccountHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
