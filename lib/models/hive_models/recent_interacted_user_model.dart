import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import '../DTO/recent_interacted_user_dto.dart';
part 'recent_interacted_user_model.g.dart';

@HiveType(typeId: 0)
class RecentUser extends HiveObject{
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String fullname;
  @HiveField(2)
  final String? avatarImage;
  @HiveField(3)
  final String? lastMessage;
  @HiveField(4)
  final int lastMessageTime;
  @HiveField(5)
  final String friendshipStatus;
  @HiveField(6)
  final String? chatId;

  RecentUser({
    required this.uid,
    required this.fullname,
    this.avatarImage,
    this.lastMessage,
    required this.lastMessageTime,
    required this.friendshipStatus,
    this.chatId,
  });

  factory RecentUser.fromDto(RecentInteractedUserDto dto) {
    return RecentUser(
      uid: dto.uid,
      fullname: dto.fullname,
      avatarImage: dto.avatarImage,
      lastMessage: dto.lastMessage,
      lastMessageTime: dto.timestamp.millisecondsSinceEpoch,
      friendshipStatus: dto.friendshipStatus,
      chatId: dto.chatId,
    );
  }

  // Convert to DTO
  RecentInteractedUserDto toDto() {
    return RecentInteractedUserDto(
      uid: uid,
      fullname: fullname,
      avatarImage: avatarImage ?? '',
      lastMessage: lastMessage ?? '',
      timestamp: Timestamp.fromMillisecondsSinceEpoch(lastMessageTime),
      friendshipStatus: friendshipStatus,
      chatId: chatId
    );
  }

  RecentUser copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    String? avatarImage,
    String? friendshipStatus,
    String? chatId
  }) {
    return RecentUser(
      uid: uid,
      fullname: fullname,
      avatarImage: avatarImage ?? this.avatarImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime?.millisecondsSinceEpoch ?? this.lastMessageTime,
      friendshipStatus: friendshipStatus ?? this.friendshipStatus,
      chatId: this.chatId
    );
  }
}
