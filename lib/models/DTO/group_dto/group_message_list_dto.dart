
import 'package:playbazaar/models/group_message.dart';

class GroupMessageListDto {
  final List<GroupMessage> messages;
  final String groupId;

  GroupMessageListDto({
    required this.messages,
    required this.groupId
  });
}