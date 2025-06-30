// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_interacted_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentUserAdapter extends TypeAdapter<RecentUser> {
  @override
  final typeId = 0;

  @override
  RecentUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentUser(
      uid: fields[0] as String,
      fullname: fields[1] as String,
      avatarImage: fields[2] as String?,
      lastMessage: fields[3] as String?,
      lastMessageTime: (fields[4] as num).toInt(),
      friendshipStatus: fields[5] as String,
      chatId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecentUser obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.fullname)
      ..writeByte(2)
      ..write(obj.avatarImage)
      ..writeByte(3)
      ..write(obj.lastMessage)
      ..writeByte(4)
      ..write(obj.lastMessageTime)
      ..writeByte(5)
      ..write(obj.friendshipStatus)
      ..writeByte(6)
      ..write(obj.chatId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
