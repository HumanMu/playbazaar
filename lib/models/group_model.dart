class GroupModel {
  String name;
  String groupIcon;
  String admin;
  List<String> members;
  String groupId;
  String recentMessage;
  String recentMessageSender;
  String groupPassword;

  GroupModel({
    required this.name,
    required this.groupIcon,
    required this.admin,
    required this.members,
    required this.groupId,
    required this.recentMessage,
    required this.recentMessageSender,
    required this.groupPassword,
  });

  // Convert Firestore document (Map) to GroupModel
  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      name: map['name'] ?? '',
      groupIcon: map['groupIcon'] ?? '',
      admin: map['admin'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      groupId: map['groupId'] ?? '',
      recentMessage: map['recentMessage'] ?? '',
      recentMessageSender: map['recentMessageSender'] ?? '',
      groupPassword: map['groupPassword'] ?? '',
    );
  }

  // Convert GroupModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'groupIcon': groupIcon,
      'admin': admin,
      'members': members,
      'groupId': groupId,
      'recentMessage': recentMessage,
      'recentMessageSender': recentMessageSender,
      'groupPassword': groupPassword,
    };
  }
}
