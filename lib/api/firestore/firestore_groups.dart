import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreGroups {
  final String? userId;
  FirestoreGroups({this.userId});
  final _db = FirebaseFirestore.instance;

  // reference to the firestore collection
  final CollectionReference userCollection
    = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection
    = FirebaseFirestore.instance.collection("groups");
  final CollectionReference friendsCollection
    = FirebaseFirestore.instance.collection("friends");

  // creating a custom group
  Future createGroup(String userName, String adminId, String groupName,
      String? groupPassword) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName" : groupName,
      "groupIcon" : "",
      "admin" : "${adminId}_$userName",
      "members" : [],
      "groupId" : "",
      "recentMessage" : "",
      "recentMessageSender" : "",
      "groupPassword" : groupPassword != ""? groupPassword : "",
    });


    // Update group members
    await groupDocumentReference.update ({
      "members" : FieldValue.arrayUnion(["${userId}_$userName"]),
      "groupId" : groupDocumentReference.id
    });

    DocumentReference userDocumentReference = userCollection.doc(userId);
    return await userDocumentReference.update({
      "groups" : FieldValue.arrayUnion(
          (["${groupDocumentReference.id}_${groupName}_$groupPassword"]))
    });   
  }



  // Retriving user data
  Future getUserByEmail( String email) async {
    QuerySnapshot snapshot = await userCollection.where(  // Return user information that has this email from firestore
        "email", isEqualTo: email).get();
    return snapshot;
  }

  getGroupsList() {
    return userCollection.doc(userId).snapshots();
  }

  // Getting the chats from a custom groups
  getChat(String groupId) async {
    return groupCollection.doc(groupId).collection("messages").orderBy("time")
        .snapshots();
  }

  // Returning group admin of the custom groups
  Future getGroupAdmin (String groupId) async {
    DocumentReference docRef = groupCollection.doc(groupId);
    DocumentSnapshot docSnap = await docRef.get();
    return docSnap["admin"];
  }

  // group member of a custom group
  getGroupMember(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // Returning search result
  searchByGroupName(String groupName) {
    return groupCollection.where("name", isEqualTo: groupName).get();
  }

  // Returning search result
  searchByUserName(String username) {
    final splitted = username.split(' ');
    return userCollection.where("firstname", isEqualTo: splitted[0]).get();
  }

  Future <bool> checkIfUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference udr = userCollection.doc(userId);
    DocumentSnapshot ds = await udr.get();

    List<dynamic> groups = await ds['groups'];
    if(groups.contains("${groupId}_$groupName")) {
      return true;
    }
    else {
      return false;
    }
  }

  Future toggleGroupMembership(
      String groupId, String userName, String groupName) async {
    DocumentReference udr = userCollection.doc(userId);
    DocumentReference gdr = groupCollection.doc(groupId);

    DocumentSnapshot ds = await udr.get();
    List<dynamic> groups = ds['groups'];

    String groupEntry = "${groupId}_$groupName".trim();
    String adminGroupEntry = "${groupId}_${groupName}_".trim();
    String memberEntry = "${userId}_$userName".trim();

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
    DocumentSnapshot updatedDs = await udr.get();
  }





  // Send message to custom groups
  sendMessage(String? groupId, Map<String, dynamic>chatMessageData ) {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime" : chatMessageData['time'].toString(),
    });
  }


}
