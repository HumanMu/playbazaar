class GroupModel {
  String name;
  String groupIcon;
  String creatorId;
  List<String> members;
  String groupId;
  String recentMessage;
  String recentMessageSender;
  bool isPublic;
  String groupPassword;

  GroupModel({
    required this.name,
    required this.groupIcon,
    required this.creatorId,
    required this.members,
    required this.groupId,
    required this.recentMessage,
    required this.recentMessageSender,
    required this.isPublic,
    required this.groupPassword,
  });

  // Convert Firestore document (Map) to GroupModel
  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      name: map['name'] ?? '',
      groupIcon: map['groupIcon'] ?? '',
      creatorId: map['creatorId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      groupId: map['groupId'] ?? '',
      recentMessage: map['recentMessage'] ?? '',
      recentMessageSender: map['recentMessageSender'] ?? '',
      isPublic: map['isPublic'],
      groupPassword: map['groupPassword'] ?? '',
    );
  }

  // Convert GroupModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'groupIcon': groupIcon,
      'creatorId': creatorId,
      'members': members,
      'groupId': groupId,
      'recentMessage': recentMessage,
      'recentMessageSender': recentMessageSender,
      'isPublic' : isPublic,
      'groupPassword': groupPassword,
    };
  }
}
