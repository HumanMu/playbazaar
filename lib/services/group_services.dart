import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/group_model.dart';

class GroupsServices {
  final String? userId;
  GroupsServices({this.userId});

  final CollectionReference userCollection
  = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection
  = FirebaseFirestore.instance.collection("groups");


  Future createGroup(String userName, String adminId, String groupName,
      String? groupPassword) async {
    GroupModel newGroup = GroupModel(
      name: groupName,
      groupIcon: "",
      admin: "${adminId}_$userName",
      members: [],
      groupId: "",
      recentMessage: "",
      recentMessageSender: "",
      groupPassword: groupPassword ?? "",
    );

    // Add the group to Firestore
    DocumentReference groupDocumentReference = await groupCollection.add(
        newGroup.toMap());

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${userId}_$userName"]),
      "groupId": groupDocumentReference.id
    });

    DocumentReference userDocumentReference = userCollection.doc(userId);
    return await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(
          (["${groupDocumentReference.id}_${groupName}_$groupPassword"]))
    });
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

  getGroupsList() {
    final result = userCollection.doc(userId).snapshots();
    return result;
  }





}