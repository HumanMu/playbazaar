
class CreateGroupDto {
  String creatorId;
  String groupName;
  String avatarImage;
  bool isPublic;
  String? groupPassword;

  CreateGroupDto({
    required this.creatorId,
    required this.groupName,
    required this.avatarImage,
    required this.isPublic,
    this.groupPassword,
  });
}
