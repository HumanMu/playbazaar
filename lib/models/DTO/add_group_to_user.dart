class AddGroupToUserDto {
  String groupId;
  String groupName;
  String avatarImage;
  bool isPublic;
  String? groupPassword;

  AddGroupToUserDto({
    required this.groupId,
    required this.groupName,
    required this.avatarImage,
    required this.isPublic,
    this.groupPassword,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId' : groupId,
      'groupName': groupName,
      'avatarImage': avatarImage,
      'isPublic' : isPublic,
      'groupPassword': groupPassword,
    };
  }
}