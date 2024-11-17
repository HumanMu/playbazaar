


class SearchFriendDto {
  String currentUserId;
  String foreignId;
  String fullname;
  String requestStatus;
  String? fcmToken;


  SearchFriendDto({
    required this.currentUserId,
    required this.foreignId,
    required this.fullname,
    required this.requestStatus,
    this.fcmToken
  });
}

