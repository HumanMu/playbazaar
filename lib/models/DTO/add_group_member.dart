

class AddGroupMemberDto {
  String groupId;
  String userName;
  String groupName;
  bool isPublic;

  AddGroupMemberDto({
    required this.groupId,
    required this.userName,
    required this.groupName,
    required this.isPublic,
  });
}


