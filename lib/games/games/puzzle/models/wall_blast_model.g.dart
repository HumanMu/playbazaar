// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wall_blast_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WallBlastModelAdapter extends TypeAdapter<WallBlastModel> {
  @override
  final int typeId = 0;

  @override
  WallBlastModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WallBlastModel(
      x: fields[0] as int,
      y: fields[1] as int,
      color: fields[2] as Color,
      isMatched: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WallBlastModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.x)
      ..writeByte(1)
      ..write(obj.y)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.isMatched);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallBlastModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
