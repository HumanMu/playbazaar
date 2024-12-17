
import '../private_message_model.dart';

class MessageListDto {
  List<PrivateMessage> message;
  String userId;


  MessageListDto({
  required this.message,
  required this.userId,
  });
}