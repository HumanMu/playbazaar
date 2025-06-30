class SearchGroupDto {
  String userId;
  String foreignId;
  String foreignName;
  String? friendStatus;
  String? foreignLastname;


  SearchGroupDto({
    required this.userId,
    required this.foreignId,
    required this.foreignName,
    this.friendStatus,
    this.foreignLastname

  });
}
