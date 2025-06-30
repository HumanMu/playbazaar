import 'package:hive_ce/hive.dart';
import '../DTO/hive_message_dto.dart';

part 'hive_message_model.g.dart';
@HiveType(typeId: 2)
class HiveMessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String receiverId;

  @HiveField(4)
  final int timestamp;

  @HiveField(5)
  final bool isRead;

  HiveMessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.isRead = false,
  });

  HiveMessageDto toDto() => HiveMessageDto(
    id: id,
    content: content,
    senderId: senderId,
    receiverId: receiverId,
    timestamp: timestamp,
    isRead: isRead,
  );
}
