
import '../private_message_model.dart';

class UserMessageListDto {
  List<PrivateMessage> messages;
  String userId;


  UserMessageListDto({
  required this.messages,
  required this.userId,
  });
}