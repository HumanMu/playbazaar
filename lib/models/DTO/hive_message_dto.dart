class HiveMessageDto {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final int timestamp;
  final bool isRead;

  HiveMessageDto({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.isRead = false,
  });
}
