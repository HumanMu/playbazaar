import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/group_model.dart';
import '../models/DTO/membership_toggler_model.dart';

class GroupServices {
  final String? userId;
  GroupServices({this.userId});

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

  Future toggleGroupMembership( MembershipTogglerModel toggle) async {
    DocumentReference udr = userCollection.doc(userId);
    DocumentReference gdr = groupCollection.doc(toggle.groupId);

    DocumentSnapshot ds = await udr.get();
    List<dynamic> groups = ds['groups'];

    String groupEntry = "${toggle.groupId}_${toggle.groupName}".trim();
    String adminGroupEntry = "${toggle.groupId}_${toggle.groupName}_".trim();
    String memberEntry = "${userId}_${toggle.userName}".trim();

    if (groups.contains(groupEntry) || groups.contains(adminGroupEntry)) {
      await udr.update({
        "groups": FieldValue.arrayRemove([groupEntry, adminGroupEntry]),
      });
      await gdr.update({
        "members": FieldValue.arrayRemove([memberEntry])
      });

      DocumentSnapshot groupSnapshot = await gdr.get();
      List<dynamic> members = groupSnapshot['members'];

      if (members.isEmpty) {
        await gdr.delete();
      }
    } else {
      await udr.update({
        "groups": FieldValue.arrayUnion([groupEntry])
      });
      await gdr.update({
        "members": FieldValue.arrayUnion([memberEntry])
      });
    }
  }

  Future <bool> checkIfUserJoined( MembershipTogglerModel toggle) async {
    DocumentReference udr = userCollection.doc(userId);
    DocumentSnapshot ds = await udr.get();

    List<dynamic> groups = await ds['groups'];
    if(groups.contains("${toggle.groupId}_${toggle.groupName}")) {
      return true;
    }
    else {
      return false;
    }
  }



}