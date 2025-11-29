import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../models/group_model.dart';
import '../functions/string_cases.dart';
import '../models/DTO/add_user_to_group_dto.dart';
import '../models/DTO/create_group_dto.dart';
import '../models/DTO/add_group_member.dart';

class GroupServices {
  final String? userId;
  GroupServices({this.userId});

  final CollectionReference userCollection
  = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection
  = FirebaseFirestore.instance.collection("groups");
  final currentUser = FirebaseAuth.instance.currentUser;


  Future createGroup(CreateGroupDto group, AddUserToGroupDto creator) async {

    GroupModel newGroup = GroupModel(
      name: group.groupName.toLowerCase(),
      groupIcon: "",
      creatorId: "${group.creatorId}_${currentUser?.displayName}",
      members: [],
      groupId: "",
      recentMessage: "",
      recentMessageSender: "",
      isPublic: group.isPublic,
      groupPassword: group.groupPassword ?? ""
    );

    try{
      // Add the group to Firestore
      DocumentReference gdr = await groupCollection.add(newGroup.toMap());

      await gdr.update({
        "members": FieldValue.arrayUnion(["${currentUser?.uid}_${currentUser?.displayName}"]),
        "groupId": gdr.id
      });

      DocumentReference udr = userCollection.doc(currentUser?.uid);
      String groupMember = "${gdr.id}_${group.groupName}_${group.isPublic}";

      return await udr.update({
        "groupsId": FieldValue.arrayUnion([groupMember])
      });
    }catch(e){
      if (kDebugMode) {
        print("Failed to add the group");
      }
      return null;
    }
  }


  Future<List<GroupModel>> fetchGroups({ DocumentSnapshot? lastDoc, int limit = 10 }) async {
    Query query = groupCollection.limit(limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      return [];
    }

    return snapshot.docs.map((doc) {
      return GroupModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<DocumentSnapshot<Object?>> getGroupsById(String id) {
    return groupCollection.doc(id).get();
  }

  Future<bool> addGroupMember(AddGroupMemberDto toggle) async {
    try{
      final currentUser = FirebaseAuth.instance.currentUser;
      DocumentReference gdr = groupCollection.doc(toggle.groupId);
      DocumentReference udr = userCollection.doc(currentUser?.uid);

      await udr.update({
        "groupsId": FieldValue.arrayUnion(["${gdr.id}_${toggle.groupName}_${toggle.isPublic}"])
      });

      await gdr.update({
        "members": FieldValue.arrayUnion(["${currentUser?.uid}_${currentUser?.displayName}"])
      });
      return true;

    }catch(e){
      if (kDebugMode) {
        print("Error trying to add group to user group list - service: $e");
      }
      return false;
    }
  }


  Future<bool> removeGroupFromUser(AddGroupMemberDto addMember) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DocumentReference udr = userCollection.doc(currentUser?.uid);
    String adminGroupEntry = "${addMember.groupId}_${addMember.groupName}_".trim();

    try {
      DocumentSnapshot userDoc = await udr.get();
      List<dynamic> userGroups = userDoc['groupsId'];

      // Check if group document exists
      String? matchedGroupId;
      List<String> recievedGroupId = splitByUnderscore(addMember.groupId);

      for (var g in userGroups) {
        String id = splitByUnderscore(g)[0];
        if (id == recievedGroupId[0]) {
          matchedGroupId = g;
        }
      }

      await udr.update({
        "groupsId": FieldValue.arrayRemove([matchedGroupId, adminGroupEntry]),
      });

      String memberEntry = "${currentUser?.uid}_${currentUser?.displayName}".trim();
      List<String> groupId = splitByUnderscore(addMember.groupId);
      DocumentReference gdr = groupCollection.doc(groupId[0]);
      DocumentSnapshot groupDoc = await gdr.get();
      List<dynamic> members = groupDoc['members'];


      await gdr.update({
        "members": FieldValue.arrayRemove([memberEntry]),
      });

      // Check if the group has no members left
      if (members.isEmpty) {
        await gdr.delete();
      }
      return true;
    }
    catch(e){
      if (kDebugMode) {
        print("Error trying to group from user grouplist - service");
      }
      return false;
    }
  }

}
