


class SearchFriendDto {
  String userId;
  String foreignId;
  String fullname;
  String requestStatus;
  String? fcmToken;


  SearchFriendDto({
    required this.userId,
    required this.foreignId,
    required this.fullname,
    required this.requestStatus,
    this.fcmToken
  });
}

