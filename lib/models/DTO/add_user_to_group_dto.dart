import '../../constants/constants.dart';
import '../../functions/enum_converter.dart';

class AddUserToGroupDto {
  String userName;
  String avatarImage;
  GroupUserRole userRole;

  AddUserToGroupDto({
    required this.userName,
    required this.avatarImage,
    required this.userRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'avatarImage': avatarImage,
      'adminStatus': groupUserRole2String(GroupUserRole.isCreator),
    };
  }
}
