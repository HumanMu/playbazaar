// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMessageModelAdapter extends TypeAdapter<HiveMessageModel> {
  @override
  final int typeId = 2;

  @override
  HiveMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMessageModel(
      id: fields[0] as String,
      content: fields[1] as String,
      senderId: fields[2] as String,
      receiverId: fields[3] as String,
      timestamp: fields[4] as int,
      isRead: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveMessageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.receiverId)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
